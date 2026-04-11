resource "random_password" "tunnel_secret" {
  length  = 64
  special = false
}

resource "cloudflare_zero_trust_tunnel_warp_connector" "connector" {
  account_id    = var.account_id
  name          = "${var.environment}-${var.site_name}"
  tunnel_secret = base64encode(random_password.tunnel_secret.result)
}

# Retrieve tunnel token via data source (not exported by the resource)
data "cloudflare_zero_trust_tunnel_warp_connector_token" "connector" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_warp_connector.connector.id
}

# Teamnet route: send this site's CIDR into the tunnel.
# The cloudflared_route resource is tunnel-type-agnostic at the teamnet API.
resource "cloudflare_zero_trust_tunnel_cloudflared_route" "site_cidr" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_warp_connector.connector.id
  network    = var.site_cidr
  comment    = "${var.site_name} site CIDR (${var.environment})"

  lifecycle {
    create_before_destroy = true
  }
}

# Private DNS: bind <site>.<suffix> to this tunnel so WARP+Gateway users
# resolve the name privately and traffic lands in the site's subnet.
resource "cloudflare_zero_trust_network_hostname_route" "site_hostname" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_warp_connector.connector.id
  hostname   = "${var.site_name}.${var.private_dns_suffix}"
  comment    = "${var.site_name} private DNS (${var.environment})"
}
