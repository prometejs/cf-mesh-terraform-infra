variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account identifier"
}

variable "private_dns_suffix" {
  type        = string
  description = "Private DNS suffix for internal site hostnames (e.g. dev.prometejs.network)"
}

variable "sites" {
  type = map(object({
    cidr         = string
    connector_ip = string
    ha_enabled   = optional(bool, false)
    ha_peer_ip   = optional(string, "")
    peers        = optional(list(string), null)
  }))
  description = "Map of site definitions keyed by site name. Omit peers to allow all-to-all connectivity between sites in environment(specified during provisioning)"

  validation {
    condition     = alltrue([for s in values(var.sites) : can(cidrnetmask(s.cidr))])
    error_message = "All site CIDRs must be valid CIDR notation"
  }

  validation {
    condition     = alltrue([for s in values(var.sites) : cidrsubnet(s.cidr, 0, 0) != cidrsubnet("100.96.0.0/12", 0, 0)])
    error_message = "Site CIDRs must not overlap with Cloudflare CGNAT range 100.96.0.0/12"
  }
}

variable "routes" {
  type = list(object({
    tunnel_id = string
    network   = string
    comment   = optional(string, "")
  }))
  default     = []
  description = "Additional teamnet routes to advertise through an existing site's mesh node tunnel"
}
