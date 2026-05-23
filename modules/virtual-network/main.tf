# Cloudflare Virtual Network (VNet); logical routing namespace inside a Zero Trust account
resource "cloudflare_zero_trust_tunnel_cloudflared_virtual_network" "this" {
  account_id         = var.account_id
  name               = "${var.environment}-vnet"
  comment            = coalesce(var.comment, "Cloudflare Mesh virtual network for ${var.environment}")
  is_default_network = var.is_default
}
