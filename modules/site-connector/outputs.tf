output "tunnel_id" {
  value       = cloudflare_zero_trust_tunnel_warp_connector.connector.id
  description = "Cloudflare WARP Connector tunnel identifier"
}

output "tunnel_token" {
  value       = data.cloudflare_zero_trust_tunnel_warp_connector_token.connector.token
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

output "private_hostname" {
  value       = cloudflare_zero_trust_network_hostname_route.site_hostname.hostname
  description = "Private FQDN for this site, resolvable only via WARP+Gateway"
}
