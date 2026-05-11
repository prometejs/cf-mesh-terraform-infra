private_dns_suffix = "dev.prometejs.network"
user_email_domain  = "prometejs.com"

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
    # ha_enabled   = true
    # ha_peer_ip   = "10.30.0.2"
  }
}