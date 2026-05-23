private_dns_suffix = "dev.prometejs.network"
user_email_domain  = "prometejs.com"

# Eight-site dev mesh.
#
# Six sites participate in the full mesh (peers omitted) and two sites
# (dev-site-lab, dev-site-quarantine) declare a narrowed `peers` list,
# producing 20 of the 28 possible inter-site pairs ≈ 71% connectivity:
#
#   full-mesh among {a, b, c, edge-lon, edge-fra, staging}     C(6,2) = 15
#   lab        ↔ {a, b, edge-lon}                                       3
#   quarantine ↔ {a, b}                                                 2
#                                                              total = 20
#
# HA is enabled on three sites (c, edge-lon, staging) so the Ansible
# playbook configures a secondary mesh node on the named peer IP.

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
  }
  "dev-site-lab" = {
    cidr         = "10.20.5.0/24"
    connector_ip = "10.20.5.1"
    peers        = ["dev-site-a", "dev-site-b", "dev-site-edge-lon"]
  }
  "dev-site-quarantine" = {
    cidr         = "10.20.6.0/24"
    connector_ip = "10.20.6.1"
    peers        = ["dev-site-a", "dev-site-b"]
  }
  "dev-site-staging" = {
    cidr         = "10.20.7.0/24"
    connector_ip = "10.20.7.1"
    ha_enabled   = true
    ha_peer_ip   = "10.20.7.2"
  }
}
