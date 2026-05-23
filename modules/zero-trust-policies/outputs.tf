output "inter_site_policy_ids" {
  value       = { for k, p in cloudflare_zero_trust_gateway_policy.allow_inter_site : k => p.id }
  description = "Gateway policy IDs for inter-site traffic, keyed by destination site name"
}

output "warp_to_sites_policy_id" {
  value       = cloudflare_zero_trust_gateway_policy.allow_warp_to_sites.id
  description = "Gateway policy ID for WARP-to-site traffic"
}

output "connector_profile_id" {
  value       = cloudflare_zero_trust_device_custom_profile.warp_connectors.id
  description = "Device profile ID for Cloudflare Mesh nodes"
}
