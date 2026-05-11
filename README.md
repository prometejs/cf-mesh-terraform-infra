# terraform-cloudflare-infra

Terraform-managed Cloudflare Zero Trust site-to-site network.

### Key features

- **Private networking via Cloudflare**: no public IPs, VPN concentrators, or hub-site hairpinning
- **DNS-based service discovery**: `site-a.<suffix>` resolves only for WARP-enrolled users; traffic routes to the site's tunnel automatically
- **Terraform-managed**: all Cloudflare resources declarative, planned on PRs, applied via workflow dispatch
- **State-sourced Ansible inventory**: single source of truth between Terraform and Ansible
- **CI/CD guardrails**

## Part of a larger stack

This repo provisions the **Cloudflare side** of the mesh only in site-to-site stack, see [notes](./NOTES.md) for more info. A new site is brought online by three repos working in order:

```mermaid
graph LR
    %% Style definitions
    classDef default fill:transparent,stroke:#333,stroke-width:1px;
    classDef linkNode fill:transparent,stroke:#0288d1,stroke-width:1px,font-weight:bold;
    classDef activeLinkNodeClass fill:transparent,stroke:#2e7d32,stroke-width:4px,font-weight:bold;

    %% Diagram nodes
    T["terraform-cloudflare-infra<br/><hr/>creates tunnels + tf-states"]:::activeLinkNodeClass
    C["cf-cloud-init<br/><hr/>first-boot provisioning"]:::linkNode
    A["ansible-cloudflare-infra<br/><hr/>day-2 config"]:::linkNode

    %% Flow connections with text notes
    T --> C
    C --- A

    %% Clickable hyperlinks (Fixed with 'href')
    click C href "https://github.com/prometejs/cf-cloud-init" "Open Cloud-Init Repo"
    click A href "https://github.com/prometejs/core-infra" "Open Ansible Repo"
```

#### Network topology

```mermaid
flowchart TB
    subgraph CF[Cloudflare Zero Trust]
        GW[Gateway<br/>network policies<br/>DNS resolver]
        TREG[Tunnel registry]
        HRR[Hostname routes<br/>a.dev.prometejs.network<br/>b.dev.prometejs.network]
        TRR[Teamnet routes<br/>10.30.0.0/24 → tun-a<br/>10.30.1.0/24 → tun-b]
        PROF[Device profiles<br/>primary_users<br/>warp_connectors]
    end

    subgraph SA[Site A - 10.30.0.0/24]
        CA[Connector Node<br/>WARP Connector A<br/>10.30.0.1]
        HOSTA[Host services]
        CA --- HOSTA
    end

    subgraph SB[Site B - 10.30.1.0/24]
        CB[Connector Node<br/>WARP Connector B<br/>10.30.1.1]
        HOSTB[Host services]
        CB --- HOSTB
    end

    subgraph USERS[WARP users]
        U1[Laptop 1]
        U2[Laptop 2]
    end

    CA -.outbound tunnel.-> TREG
    CB -.outbound tunnel.-> TREG
    U1 -.WARP.-> GW
    U2 -.WARP.-> GW
    GW --- PROF
    GW --- HRR
    GW --- TRR
    TRR -.-> CA
    TRR -.-> CB
```

## Setup Requirements

### Tooling

| Tool | Version |
|---|---|
| Terraform | `>= 1.8.0` |
| Cloudflare provider | `~> 5.17` (tested on 5.18.0) |
| Ansible provider (`ansible/ansible`) | `~> 1.3` |
| Random provider | `~> 3.6` |
| Ansible core | `>= 2.15` |
| Ansible collection | `cloud.terraform` (for the `terraform_provider` inventory plugin) |

### Accounts

- **Cloudflare**: Zero Trust enabled. API token scoped to: `Account:Cloudflare Tunnel:Edit`, `Account:Zero Trust:Edit`, `Account:Access:Apps and Policies:Edit`, `Zone:DNS:Edit`
- **AWS**: S3 bucket + DynamoDB table for Terraform state (S3 backend with DynamoDB locking)

### Environment configuration

Create `dev` and `prod` environments in repo Settings → Environments, then set the following at the **environment** level:

| Secrets | Variables |
|---|---|
| `CLOUDFLARE_API_TOKEN` | `CLOUDFLARE_ACCOUNT_ID` → `TF_VAR_cloudflare_account_id` |
| `AWS_ACCESS_KEY_ID` | `CLOUDFLARE_ZONE_ID` → `TF_VAR_cloudflare_zone_id` |
| `AWS_SECRET_ACCESS_KEY` | |

## Ansible inventory contract

The root module does not emit an `ansible_inventory` output. Instead it creates resources from the `ansible/ansible` provider that the inventory plugin reads from Terraform state.

## Usage

### Local plan (read-only, dev)

```bash
export CLOUDFLARE_API_TOKEN=...
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export TF_VAR_cloudflare_account_id=...
export TF_VAR_cloudflare_zone_id=...

terraform init
terraform workspace select -or-create=true dev
terraform plan -var-file=environments/dev.tfvars
```

### Deployment

```mermaid
flowchart LR
    PR[Open PR] --> PLAN[plan.ymldflook sticky comment]
    PLAN -->|review & merge| MAIN[main branch]
    MAIN --> DISPATCH[Manual dispatchapply.yml workspace=dev/prod]
    DISPATCH --> REPLAN[plan.ymlworkflow_call]
    REPLAN --> ARTIFACT[Upload tfplan.binaryartifact]
    ARTIFACT --> APPLY[apply jobdownload artifactdetect new sitesterraform apply tfplan.binary]
    APPLY --> SUMMARY[summary jobif: alwaysjob summary + annotations]
    APPLY --> STATE[(S3 stateansible_host resources)]
```

- **dev:** Actions → **Terraform Apply** → Run workflow → workspace `dev`
- **prod:** same, workspace `prod`. The apply pauses for required reviewers configured on the `prod` environment.
- **Staged single-site cutover:** run locally with `terraform apply -target=module.site[\"<name>\"]` against the prod workspace. `apply.yml` does not expose a `-target` input.

### Testing

see [fixtures](./fixtures/test.tfvars) for sample data

## License

MIT — see [LICENSE.md](./LICENSE.md).