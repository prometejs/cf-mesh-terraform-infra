# Gateway network policy: allow inter-site traffic
resource "cloudflare_zero_trust_gateway_policy" "allow_inter_site" {
  account_id  = var.account_id
  name        = "${var.environment}-allow-inter-site-traffic"
  description = "Allow traffic between site CIDRs in ${var.environment}"
  precedence  = 1
  action      = "allow"
  enabled     = true
  filters     = ["l4"]

  traffic = join(" or ", [
    for name, cidr in var.site_cidrs :
    "net.dst.ip in {${cidr}}"
  ])
}

# Gateway network policy: allow WARP client to site traffic
resource "cloudflare_zero_trust_gateway_policy" "allow_warp_to_sites" {
  account_id  = var.account_id
  name        = "${var.environment}-allow-warp-to-sites"
  description = "Allow WARP client traffic to site networks in ${var.environment}"
  precedence  = 2
  action      = "allow"
  enabled     = true
  filters     = ["l4"]

  traffic = join(" or ", [
    for name, cidr in var.site_cidrs :
    "net.dst.ip in {${cidr}}"
  ])
}

# Device profile for WARP Connectors (site-side pseudo-user)
# v5: service_mode -> service_mode_v2, exclude is an attribute (list of objects)
resource "cloudflare_zero_trust_device_custom_profile" "warp_connectors" {
  account_id    = var.account_id
  name          = "${var.environment}-warp-connectors"
  description   = "Profile for WARP Connector devices in ${var.environment}"
  match         = "warp_connector@cloudflareaccess.com"
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

# Primary user-facing device profile.
# Matches users by email domain and forces DNS resolution through Cloudflare
# Gateway so private hostnames (e.g. site-a.<suffix>) resolve via the internal
# DNS hostname routes instead of the device's local resolver.
resource "cloudflare_zero_trust_device_custom_profile" "primary_users" {
  account_id  = var.account_id
  name        = "${var.environment}-primary-users"
  description = "Primary WARP+Gateway profile for ${var.environment} users"
  match       = "identity.email matches \".*@${var.user_email_domain}$\""
  precedence  = 10
  enabled     = true

  auto_connect          = 0
  switch_locked         = true
  allow_mode_switch     = false
  disable_auto_fallback = true

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
