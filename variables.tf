variable "cloudflare_api_token" {
  type        = string
  sensitive   = true
  description = "Scoped Cloudflare API token with Zero Trust, DNS, and Access permissions"
}

variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account identifier"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare DNS zone identifier"
}

variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region for S3 state backend"
}

variable "sites" {
  type = map(object({
    cidr         = string
    connector_ip = string
    ha_enabled   = optional(bool, false)
    ha_peer_ip   = optional(string, "")
  }))
  description = "Map of site definitions keyed by site name"

  validation {
    condition = alltrue([
      for s in values(var.sites) : can(cidrnetmask(s.cidr))
    ])
    error_message = "All site CIDRs must be valid CIDR notation."
  }

  validation {
    condition = alltrue([
      for s in values(var.sites) : !cidrsubnet(s.cidr, 0, 0) == cidrsubnet("100.96.0.0/12", 0, 0)
    ])
    error_message = "Site CIDRs must not overlap with Cloudflare CGNAT range 100.96.0.0/12."
  }
}
