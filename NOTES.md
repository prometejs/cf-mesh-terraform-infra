A Cloudflare Zero Trust any-to-any mesh network built on **Cloudflare Mesh** (formerly WARP Connector - see the [April 2026 rebrand changelog](https://developers.cloudflare.com/changelog/post/2026-04-14-cloudflare-mesh/)). 

A **mesh node** runs at each physical or virtual site and advertises its local IPv4/IPv6 subnets to the Cloudflare global network, creating secure, bidirectional site-to-site and client-to-site connectivity via private IP routing.

Four things make the mesh work:

1. **A Virtual Network per workspace** scopes every CIDR route below to a single environment's routing namespace.
2. **Mesh node tunnels** on each site terminate into Cloudflare's edge.
3. **Teamnet routes** tell Cloudflare "CIDR X belongs on tunnel Y" (inside this workspace's VNet).
4. **Private DNS hostname routes** bind a FQDN to a tunnel, resolvable only through Cloudflare Gateway. Hostname routes are tunnel-scoped — they inherit VNet isolation from the CIDR routes underneath.
  
## Components

### Cloudflare Zero Trust

- **What:** Cloudflare's account-level security & networking plane.
- **Does:** Hosts the mesh node registry, teamnet route table, Gateway DNS resolver, Gateway network policies, device profiles.
- **Why:** Replaces the traditional VPN concentrator. Every site connects outbound to Cloudflare's edge; limited to none public attack surface on the sites themselves.

### Virtual Network (per workspace)

- **What:** A `cloudflare_zero_trust_tunnel_cloudflared_virtual_network` resource created once per Terraform workspace by `modules/virtual-network`.
- **Does:** Provides a logical routing namespace inside the Zero Trust account. Every teamnet route and every private DNS hostname route in this workspace is pinned to its VNet via `virtual_network_id`.
- **Why:** Two VNets on the same account may advertise overlapping CIDRs without conflict; so `dev` and `prod` can use the same `10.20.0.0/24` blocks without colliding. It also makes per-environment cleanup trivial: deleting a workspace tears down its VNet and orphans nothing into the account default.

### Cloudflare Mesh node (per site)

- **What:** A Cloudflare-provided binary (`cloudflare-warp` running in mesh-node mode, formerly "WARP Connector" mode) installed on a host inside the site's subnet.
- **Does:** Opens an outbound encrypted tunnel to Cloudflare. Accepts traffic from Cloudflare destined for its advertised CIDR and forwards it onto the local network.
- **Why:** Unlike the older `cloudflared` tunnel (which is hostname/ingress oriented), a Cloudflare Mesh node advertises a whole subnet. That is what enables CIDR-level routing between sites.

### Teamnet routes (CIDR advertisement)

- **What:** Entries in Cloudflare's internal routing table that map a CIDR to a tunnel UUID, scoped to a Virtual Network.
- **Does:** Tell Cloudflare Gateway, "packets destined for `10.10.0.0/24` inside VNet `<vnet-id>` should be sent into tunnel `<uuid>`."
- **Why:** Without these, Cloudflare knows the tunnel exists but has no idea which subnet lives behind it. Scoping to a VNet means dev and prod can advertise the same CIDR through different tunnels without collision.

### Private DNS (hostname routes)

- **What:** cloudflare_zero_trust_network_hostname_route resources bind a private FQDN to a specific tunnel.
- **Does:** Cloudflare Gateway DNS resolves these hostnames exclusively for WARP clients, routing traffic through the tunnel without exposing names to public DNS.
- **Why:** Replaces insecure public DNS records with a native, private internal DNS mechanism that eliminates public leaks, on-premise resolvers, and split-horizon configurations.

### Gateway network policies

- **What:** Layer 4 firewall allow-rules configured in `modules/zero-trust-policies/main.tf`.
- **Does:**
  - `${env}-allow-to-<site>` — one rule per destination site, naming the specific source CIDRs allowed to reach it. Generated from each site's `peers` declaration (see below).
  - `${env}-allow-warp-to-sites` — allow WARP client traffic (source restricted to the CGNAT range `100.96.0.0/12`) into any site CIDR.
- **Why:** Gateway defaults to deny-by-default for traffic steered through it. Without these rules, even with working mesh node tunnels and DNS, packets would be dropped by Gateway inspection.

#### Partial connectivity via `peers`

Each entry in `var.sites` accepts an optional `peers` list:

- `peers` omitted (default) allows site participate in the full mesh and is reachable from all nodes in the environment.
- `peers = ["site-x", "site-y"]` — the site is reachable only from the named sites.
- `peers = []` — the site is not reachable from other nodes.

### Device profiles

- **`warp_connectors`** profile: Matches the `warp_connector@cloudflareaccess.com` service identity used by Cloudflare Mesh nodes. Disables traffic proxying on mesh nodes to prevent routing loops.

### Terraform state + Ansible inventory bridge

- **What:** `ansible_host.site` and `ansible_group` resources from the `ansible/ansible` provider, written into Terraform state.
- **Does:** Serialises a dynamic ansible inventory as structured state.
- **Why:** Terraform is the source of truth for which sites exist and their registration tokens. Exporting a file would create drift; reading state directly eliminates it.

## Design decisions
Geared towards a site-to-site mesh for which we need subnet-level advertisement, and completely eliminates the need for public IP exposure, legacy site-to-site VPN tunnels, and centralized hub-and-spoke hardware concentrators.

### Why Cloudflare Mesh?

- [Meets design requirements](#design-decisions)
- **No public ingress.** Every mesh node dials out; site firewalls stay closed.
- **Unified identity plane.** User access, device posture, Gateway policies, and tunnel routing all live in the same account and cross-reference each other natively.
- **Encrypted by default, no key management.** The control plane handles rotation, mesh-node auth, and session keys.
- **Mesh without a hub.** Every site is equidistant from every other site at Cloudflare's edge.

### Why Not cloudflared?

`cloudflared` is ingress-oriented and publishes specific hostnames/ports from a single origin. 

### Why split Terraform and Ansible

- **Terraform** is the right tool for declarative API state: Cloudflare resources, registration tokens, DNS records, routes. It is wrong for imperative host provisioning.
- **Ansible** is the right tool for "SSH to the connector host, install the package, write the config, enable the systemd unit." It is wrong for managing cloud resources.
- The bridge is the Terraform state file, read via the `cloud.terraform.terraform_provider` inventory plugin. No intermediate inventory file, no sync job, no drift.

### Why DNS-based service routing

- **Stable.** Service names don't change when a connector host is replaced or an IP shifts inside the subnet.
- **Discoverable.** The convention `<site-name>.<suffix>` is grep-able, obvious, and mirrors the Terraform site names exactly.
- **Private.** Hostname routes only resolve over WARP+Gateway. The same name on a non-WARP device returns `NXDOMAIN`. No accidental leakage.
- **Tunnel-bound, not host-bound.** A hostname route points at a mesh node tunnel, not an IP. The tunnel covers the whole subnet, so the name reaches anything on the site LAN.

### Per-environment DNS suffixes

`dev` uses `dev.prometejs.network`; `prod` uses `prometejs.network`. Allows fully isolated private namespaces on the same Cloudflare account.

## Request flow

Two canonical flows matter: **site → site** and **DNS resolution**. 

### DNS resolution

```mermaid
sequenceDiagram
    participant C as Client<br/>(WARP-enrolled)
    participant W as WARP Client<br/>(local)
    participant G as Cloudflare Gateway<br/>DNS resolver
    participant ZT as Zero Trust<br/>hostname routes
    C->>W: dig site-b.prometejs.network
    W->>G: DoH query (forced by profile)
    G->>ZT: lookup hostname route
    ZT-->>G: tunnel_id for site-b
    G-->>W: answer (CGNAT IP bound to tunnel)
    W-->>C: DNS response
```

**NB**: the answer IP is a Cloudflare-managed CGNAT address. It has no meaning outside the WARP tunnel. A non-WARP device asking a public resolver for the same name gets `NXDOMAIN`.

### Site → site 

```mermaid
sequenceDiagram
    participant HA as Host on site A<br/>(behind mesh node A)
    participant TA as Mesh Node A
    participant CFE as Cloudflare edge
    participant GW as Gateway network policy
    participant TB as Mesh Node B
    participant HB as Host on site B
    HA->>TA: packet to site-b.prometejs.network<br/>(DNS already resolved)
    TA->>CFE: tunnel out
    CFE->>GW: packet inspected
    GW->>GW: match allow_inter_site_traffic
    GW->>TB: forward into site B mesh node tunnel
    TB->>HB: forward onto site B LAN
```

## Caveats

Changing Terraform resource types forces a destructive replacement, rotating the tunnel ID and token. Production migration requires targeting one site at a time locally (`-target=module.site[\"<name>\"]`) and running the Ansible playbook sequentially to prevent simultaneous outages. The apply.yml workflow excludes -target to ensure this manual escape hatch is not automated.

This caveat is the reason the Cloudflare Mesh rebrand was applied as a *documentation-only* change in this repo; the Cloudflare provider continues to publish the resource type as `cloudflare_zero_trust_tunnel_warp_connector`, and renaming it (or its labels) in this codebase would force a destructive recreate of every mesh node.
