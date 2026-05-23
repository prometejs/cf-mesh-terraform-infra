# Gateway network policies: allow inter-site traffic.
# Cloudflare requires a UNIQUE precedence per Gateway rule in an account, so
# we derive it deterministically from the sorted destination CIDR's position
# in the for_each map. Base of 100 leaves precedences 1–99 free for any
# hand-managed rules elsewhere in the account.
resource "cloudflare_zero_trust_gateway_policy" "allow_inter_site" {
  for_each = var.site_peers

  account_id  = var.account_id
  name        = "site-${replace(replace(each.key, "/", "-"), ".", "_")}-traffic-policy"
  description = "Allow traffic from listed peers to ${each.key} in ${var.environment}"
  precedence  = 100 + index(sort(keys(var.site_peers)), each.key)
  action      = "allow"
  enabled     = true
  filters     = ["l4"]

  traffic = format(
    "net.src.ip in {%s} and net.dst.ip in {%s}",
    join(" ", concat(["100.96.0.0/12"], each.value)),
    each.key
  )
}

# Mesh nodes device profile (site-side service identity).
# The `match` attribute must be a Wirefilter expression, not a bare string —
# we match the WARP Connector service identity's email exactly.
resource "cloudflare_zero_trust_device_custom_profile" "warp_connectors" {
  account_id    = var.account_id
  name          = "${var.environment}-nodes"
  description   = "Profile for Cloudflare Mesh node devices (WARP connectors) in ${var.environment}"
  match         = "identity.email == \"warp_connector@cloudflareaccess.com\""
  precedence    = 1
  enabled       = true
  auto_connect  = 0
  switch_locked = true

  service_mode_v2 = {
    mode = "warp"
  }

  exclude = [
    {
      address     = "100.96.0.0/12"
      description = "Cloudflare CGNAT"
    }
  ]
}
