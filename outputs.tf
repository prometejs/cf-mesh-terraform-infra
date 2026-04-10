# --------------------------------------------------------------------------
# Structured outputs for Ansible and CI/CD consumption
# --------------------------------------------------------------------------

output "site_inventory" {
  value = {
    for name, site in module.site : name => {
      tunnel_id    = site.tunnel_id
      tunnel_token = site.tunnel_token
      cidr         = site.site_cidr
      connector_ip = site.connector_ip
      dns_record_id = site.dns_record_id
      environment  = terraform.workspace
    }
  }
  sensitive   = true
  description = "Structured site inventory for Ansible consumption"
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
