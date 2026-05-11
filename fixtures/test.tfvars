private_dns_suffix = "test.prometejs.network"
user_email_domain  = "prometejs.com"

sites = {
  "test-site-0" = {
    cidr         = "10.20.0.0/24"
    connector_ip = "10.20.0.1"
  }
  "test-site-a" = {
    cidr         = "10.20.1.0/24"
    connector_ip = "10.20.1.1"
    ha_enabled   = true
    ha_peer_ip   = "10.20.1.2"
  }
  "test-site-b" = {
    cidr         = "10.20.2.0/24"
    connector_ip = "10.20.2.1"
  }
}
