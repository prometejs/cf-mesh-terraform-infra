output "tunnel_id" {
  value       = cloudflare_zero_trust_tunnel_cloudflared.connector.id
  description = "Cloudflare tunnel identifier"
}

output "tunnel_token" {
  value       = data.cloudflare_zero_trust_tunnel_cloudflared_token.connector.token
  sensitive   = true
  description = "Token used to register the WARP Connector on the host"
}

output "tunnel_secret" {
  value       = base64encode(random_password.tunnel_secret.result)
  sensitive   = true
  description = "Tunnel secret (base64 encoded)"
}

output "site_cidr" {
  value       = var.site_cidr
  description = "Site CIDR block"
}

output "connector_ip" {
  value       = var.connector_ip
  description = "WARP Connector host IP"
}

output "site_name" {
  value       = var.site_name
  description = "Site name identifier"
}

output "dns_record_id" {
  value       = cloudflare_dns_record.site_connector.id
  description = "DNS record ID for the site connector"
}
