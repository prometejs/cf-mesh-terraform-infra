private_dns_suffix = "dev.prometejs.network"
user_email_domain  = "prometejs.com"

sites = {
  "dev-site-a" = {
    cidr         = "10.10.0.0/24"
    connector_ip = "10.10.0.1"
  }
  "dev-site-b" = {
    cidr         = "10.10.1.0/24"
    connector_ip = "10.10.1.1"
  }
}
