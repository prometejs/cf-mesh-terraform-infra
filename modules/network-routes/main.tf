resource "cloudflare_zero_trust_tunnel_cloudflared_route" "routes" {
  for_each = { for i, r in var.routes : tostring(i) => r }

  account_id = var.account_id
  tunnel_id  = each.value.tunnel_id
  network    = each.value.network
  comment    = coalesce(each.value.comment, "${each.key} route (${var.environment})")

  lifecycle {
    create_before_destroy = true
  }
}