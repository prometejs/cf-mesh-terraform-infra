> **Rebrand note (April 2026):** Cloudflare renamed *WARP Connector* to **Cloudflare Mesh**, with each connector now referred to as a **mesh node** — see the [Cloudflare Mesh changelog](https://developers.cloudflare.com/changelog/post/2026-04-14-cloudflare-mesh/). The rebrand is non-breaking: existing deployments and resources keep working without migration.

# cf-mesh-terraform-infra

Terraform-managed dedicated **Cloudflare Mesh** network. **Cloudflare side** of a site-to-site provisioning stack.

```mermaid
graph LR
    %% Style definitions
    classDef default fill:transparent,stroke:#333,stroke-width:1px;
    classDef linkNode fill:transparent,stroke:#0288d1,stroke-width:1px,font-weight:bold;
    classDef activeLinkNodeClass fill:transparent,stroke:#2e7d32,stroke-width:4px,font-weight:bold;

    %% Diagram nodes
    T["cf-mesh-terraform-infra<br/><hr/>creates mesh node tunnels + tf-states"]:::activeLinkNodeClass
    C["cf-cloud-init<br/><hr/>first-boot provisioning"]:::linkNode
    A["ansible-cloudflare-infra<br/><hr/>day-2 config"]:::linkNode

    %% Flow connections with text notes
    T --> C
    C --- A

    %% Clickable hyperlinks (Fixed with 'href')
    click C href "https://github.com/prometejs/cf-mesh-cloud-init" "Open Cloud-Init Repo"
    click A href "https://github.com/prometejs/cf-mesh-site-config" "Open Ansible Repo"
```

#### Features

- **Private networking via Cloudflare**: no public IPs, VPN concentrators, or hub-site hairpinning
- **DNS-based service discovery**: `site-a.<suffix>` resolves only for WARP-enrolled users; traffic routes to the site's mesh node automatically
- **Terraform-managed**: all Cloudflare resources declarative, planned on PRs, applied via workflow dispatch
- **State-sourced Ansible inventory**: single source of truth between Terraform and Ansible via an _Ansible inventory contract_
- **CI/CD guardrails**

see [notes](./NOTES.md) for more info.

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

#### Network topology

```mermaid
flowchart TB
    subgraph CF[Cloudflare Zero Trust]
        GW[Gateway<br/>network policies<br/>DNS resolver]
        TREG[Mesh node registry]
        HRR[Hostname routes<br/>a.dev.prometejs.network<br/>b.dev.prometejs.network]
        TRR[Teamnet routes<br/>10.30.0.0/24 → mesh-a<br/>10.30.1.0/24 → mesh-b]
        PROF[Device profiles<br/>primary_users<br/>mesh_nodes]
    end

    subgraph SA[Site A - 10.30.0.0/24]
        CA[Cloudflare Mesh Node A<br/>10.30.0.1]
        HOSTA[Host services]
        CA --- HOSTA
    end

    subgraph SB[Site B - 10.30.1.0/24]
        CB[Cloudflare Mesh Node B<br/>10.30.1.1]
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

    classDef cfStyle fill:transparent,stroke:#f38020,stroke-width:1px,color:#f38020
    classDef siteAStyle fill:transparent,stroke:#0284c7,stroke-width:1px,color:#0284c7
    classDef siteBStyle fill:transparent,stroke:#0d9488,stroke-width:1px,color:#0d9488
    classDef usersStyle fill:transparent,stroke:#be185d,stroke-width:1px,color:#be185d

    class CF cfStyle
    class SA siteAStyle
    class SB siteBStyle
    class USERS usersStyle
```

### Testing

see [fixtures](./fixtures/dev.tfvars) for sample data

## License

MIT — see [LICENSE.md](./LICENSE.md).

