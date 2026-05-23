# --------------------------------------------------------------------------
# Structured outputs for Ansible and CI/CD consumption
# --------------------------------------------------------------------------

output "site_inventory" {
  value = {
    for name, site in module.site : name => {
      tunnel_id        = site.tunnel_id
      tunnel_token     = site.tunnel_token
      cidr             = site.site_cidr
      connector_ip     = site.connector_ip
      private_hostname = site.private_hostname
      environment      = terraform.workspace
    }
  }
  sensitive   = true
  description = "Structured site inventory for Ansible consumption"
  # ( SSH target, `ha_enabled`, `ha_peer_ip`, `remote_cidrs` can be added here as needed )
}

output "site_names" {
  value       = keys(module.site)
  description = "List of deployed site names"
}

output "site_cidrs" {
  value       = { for name, site in module.site : name => site.site_cidr }
  description = "Map of site names to their CIDR blocks"
}

output "tunnel_ids" {
  value       = { for name, site in module.site : name => site.tunnel_id }
  description = "Map of site names to their Cloudflare tunnel IDs"
}

output "environment" {
  value       = terraform.workspace
  description = "Current Terraform workspace / environment"
}

output "extra_route_ids" {
  value       = module.extra_routes.route_ids
  description = "Map of extra teamnet route names to their Cloudflare route IDs"
}
