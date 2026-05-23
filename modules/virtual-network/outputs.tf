output "id" {
  value       = cloudflare_zero_trust_tunnel_cloudflared_virtual_network.this.id
  description = "Cloudflare Virtual Network identifier"
}

output "name" {
  value       = cloudflare_zero_trust_tunnel_cloudflared_virtual_network.this.name
  description = "Cloudflare Virtual Network name"
}
