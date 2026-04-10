output "inter_site_policy_id" {
  value       = cloudflare_zero_trust_gateway_policy.allow_inter_site.id
  description = "Gateway policy ID for inter-site traffic"
}

output "warp_to_sites_policy_id" {
  value       = cloudflare_zero_trust_gateway_policy.allow_warp_to_sites.id
  description = "Gateway policy ID for WARP-to-site traffic"
}

output "connector_profile_id" {
  value       = cloudflare_zero_trust_device_custom_profile.warp_connectors.id
  description = "Device profile ID for WARP Connectors"
}
