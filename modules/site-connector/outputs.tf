output "tunnel_id" {
  value       = cloudflare_zero_trust_tunnel_warp_connector.connector.id
  description = "Cloudflare Mesh node tunnel identifier"
}

output "tunnel_token" {
  value       = data.cloudflare_zero_trust_tunnel_warp_connector_token.connector.token
  sensitive   = true
  description = "Token used to register the Cloudflare Mesh node on the host"
}

output "tunnel_secret" {
  value       = base64encode(random_password.tunnel_secret.result)
  sensitive   = true
  description = "Tunnel secret (base64 encoded)"
}

output "site_cidr" {
  value       = var.cidr
  description = "Site CIDR block"
}

output "connector_ip" {
  value       = var.connector_ip
  description = "Cloudflare Mesh node host IP"
}

output "site_name" {
  value       = var.name
  description = "Site name identifier"
}
