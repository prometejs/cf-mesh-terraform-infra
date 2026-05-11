private_dns_suffix = "test.prometejs.network"
user_email_domain  = "prometejs.com"

sites = {
  "test-site-a" = {
    cidr         = "10.20.0.0/24"
    connector_ip = "10.20.0.1"
  }
  "test-site-b" = {
    cidr         = "10.20.1.0/24"
    connector_ip = "10.20.1.1"
  }
  "test-site-c" = {
    cidr         = "10.20.2.0/24"
    connector_ip = "10.20.2.1"
  }
}
