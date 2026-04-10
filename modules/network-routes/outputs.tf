output "route_ids" {
  value       = { for k, r in cloudflare_zero_trust_tunnel_cloudflared_route.routes : k => r.id }
  description = "Map of route names to their Cloudflare route IDs"
}
