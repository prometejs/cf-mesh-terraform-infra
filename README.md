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
    C["cf-mesh-cloud-init<br/><hr/>first-boot provisioning"]:::linkNode
    A["cf-mesh-site-config<br/><hr/>day-2 config"]:::linkNode
    N["cf-mesh-node-agent<br/><hr/>day-2 config"]:::linkNode

    %% Flow connections with text notes
    T --> C
    T --> A
    C --> A
    N --> C

    %% Clickable hyperlinks (Fixed with 'href')
    click C href "https://github.com/prometejs/cf-mesh-cloud-init" "Open Cloud-Init Repo"
    click A href "https://github.com/prometejs/cf-mesh-site-config" "Open Ansible Repo"
    click N href "https://github.com/prometejs/cf-mesh-node-agent" "Node Agent Repo"
```

#### Features

- **Private networking via Cloudflare**: no public IPs, VPN concentrators, or hub-site hairpinning
- **DNS-based service discovery**: `site-a.<suffix>` resolves only for WARP-enrolled devices; traffic routes to the site's mesh node automatically
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

| Variable | Terraform Side |
|---|---|
| `CLOUDFLARE_API_TOKEN` | `CLOUDFLARE_API_TOKEN` → `TF_VAR_cloudflare_api_token` |
| `CLOUDFLARE_ACCOUNT_ID` | `CLOUDFLARE_ACCOUNT_ID` → `TF_VAR_cloudflare_account_id` |
| `CLOUDFLARE_ZONE_ID` | `CLOUDFLARE_ZONE_ID` → `TF_VAR_cloudflare_zone_id` |
| `AWS_ACCESS_KEY_ID` | |
| `AWS_SECRET_ACCESS_KEY` | |

### Usage Example
Local plan (read-only, dev)
```
export CLOUDFLARE_API_TOKEN=...
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export TF_VAR_cloudflare_account_id=...
export TF_VAR_cloudflare_zone_id=...

terraform init
terraform workspace select -or-create=true dev
terraform plan -var-file=environments/dev.tfvars
```

### Testing

see [fixtures](./fixtures/dev.tfvars) for sample data

## License

MIT — see [LICENSE.md](./LICENSE.md).
