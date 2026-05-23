private_dns_suffix = "dev.prometejs.network"

# Eight-site dev mesh.
#
# Under the current schema, each site's `peers` list is the set of source
# CIDRs allowed TO REACH that site (an ingress allowlist consumed verbatim
# by local.site_peers and rendered into `net.src.ip in {...}` Gateway
# expressions). Sites that omit `peers` accept any other site as a source.
# Cloudflare's CGNAT range is prepended automatically by the policy module
# so WARP clients can always reach every site.
#
# Allowed directed (src → dst) flows in this fixture:
#
#   peers=null on a, b, c, edge-lon          4 sites × 7 sources = 28
#   edge-fra peers = [a, b, edge-lon, staging]                     4
#   staging  peers = [a, b, c, edge-lon]                           4
#   lab      peers = [a, b, edge-lon]                              3
#   quarantine peers = [a]                                         1
#                                                       total =   40
#
#   40 of 56 possible directed inter-site flows ≈ 71% interconnected
#
# HA is enabled on three sites (c, edge-lon, staging) so the Ansible
# playbook configures a secondary mesh node on the named peer IP. (TBC)

sites = {
  "dev-site-a" = {
    cidr         = "10.20.0.0/24"
    connector_ip = "10.20.0.1"
  }
  "dev-site-b" = {
    cidr         = "10.20.1.0/24"
    connector_ip = "10.20.1.1"
  }
  "dev-site-c" = {
    cidr         = "10.20.2.0/24"
    connector_ip = "10.20.2.1"
    ha_enabled   = true
    ha_peer_ip   = "10.20.2.2"
  }
  "dev-site-edge-lon" = {
    cidr         = "10.20.3.0/24"
    connector_ip = "10.20.3.1"
    ha_enabled   = true
    ha_peer_ip   = "10.20.3.2"
  }
  "dev-site-edge-fra" = {
    cidr         = "10.20.4.0/24"
    connector_ip = "10.20.4.1"
    peers = [
      "10.20.0.0/24", # dev-site-a
      "10.20.1.0/24", # dev-site-b
      "10.20.3.0/24", # dev-site-edge-lon
      "10.20.7.0/24", # dev-site-staging
    ]
  }
  "dev-site-lab" = {
    cidr         = "10.20.5.0/24"
    connector_ip = "10.20.5.1"
    peers = [
      "10.20.0.0/24", # dev-site-a
      "10.20.1.0/24", # dev-site-b
      "10.20.3.0/24", # dev-site-edge-lon
    ]
  }
  "dev-site-quarantine" = {
    cidr         = "10.20.6.0/24"
    connector_ip = "10.20.6.1"
    peers = [
      "10.20.0.0/24", # dev-site-a
    ]
  }
  "dev-site-staging" = {
    cidr         = "10.20.7.0/24"
    connector_ip = "10.20.7.1"
    ha_enabled   = true
    ha_peer_ip   = "10.20.7.2"
    peers = [
      "10.20.0.0/24", # dev-site-a
      "10.20.1.0/24", # dev-site-b
      "10.20.2.0/24", # dev-site-c
      "10.20.3.0/24", # dev-site-edge-lon
    ]
  }
}

# Additional teamnet routes published through an existing site's mesh node tunnel. tunnel_id` must be a REAL tunnel UUID from this account. 
routes = []
# Example shape once you have real tunnel IDs:
# routes = [
#   {
#     tunnel_id = "<uuid-of-dev-site-a-tunnel>"
#     network   = "10.30.20.0/24"
#     comment   = "Secondary VLAN behind dev-site-a"
#   },
#   {
#     tunnel_id = "<uuid-of-dev-site-edge-lon-tunnel>"
#     network   = "10.40.0.0/22"
#     comment   = "IoT subnet reachable via dev-site-edge-lon"
#   },
# ]
