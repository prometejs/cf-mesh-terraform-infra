sites = {
  "prod-site-a" = {
    cidr         = "10.30.0.0/24"
    connector_ip = "10.30.0.1"
    ha_enabled   = true
    ha_peer_ip   = "10.30.0.2"
  }
  "prod-site-b" = {
    cidr         = "10.30.1.0/24"
    connector_ip = "10.30.1.1"
    ha_enabled   = true
    ha_peer_ip   = "10.30.1.2"
  }
}
