resource "random_password" "tunnel_secret" {
  length  = 64
  special = false
}

resource "cloudflare_zero_trust_tunnel_warp_connector" "connector" {
  account_id    = var.account_id
  name          = "${var.environment}-${var.name}"
  tunnel_secret = base64encode(random_password.tunnel_secret.result)
}

# Teamnet route: send this site's CIDR into the mesh node tunnel.
# Pinned to the workspace's VNet so dev/prod can advertise overlapping
# CIDRs on the same account without colliding.
resource "cloudflare_zero_trust_tunnel_cloudflared_route" "site_cidr" {
  account_id         = var.account_id
  tunnel_id          = cloudflare_zero_trust_tunnel_warp_connector.connector.id
  network            = var.cidr
  comment            = "${var.name} site CIDR (${var.environment})"
  virtual_network_id = var.virtual_network_id

  lifecycle {
    create_before_destroy = true
  }
}