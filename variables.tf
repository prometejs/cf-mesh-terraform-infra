variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare account identifier"
}

variable "sites" {
  type = map(object({
    cidr         = string
    connector_ip = string
    mac          = string
    ha_enabled   = optional(bool, false)
    ha_peer_ip   = optional(string, "")
    peers        = optional(list(string), null)
    location     = optional(string, "")
  }))
  description = <<EOT
    Map of site definitions keyed by site name.
    Omit peers for all-to-all connectivity.
    'mac' and 'location' are operational state tags surfaced as a JSON 'tags' variable.
    They are not attached to the Cloudflare tunnel due to provider limitations.
  EOT 

  validation {
    condition     = alltrue([for s in values(var.sites) : can(cidrnetmask(s.cidr))])
    error_message = "All site CIDRs must be valid CIDR notation"
  }

  validation {
    condition     = alltrue([for s in values(var.sites) : cidrsubnet(s.cidr, 0, 0) != cidrsubnet("100.96.0.0/12", 0, 0)])
    error_message = "Site CIDRs must not overlap with Cloudflare CGNAT range 100.96.0.0/12"
  }

  validation {
    condition     = alltrue([for s in values(var.sites) : s.node_mac == "" || can(regex("^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$", s.node_mac))])
    error_message = "node_mac must be a valid MAC address (xx:xx:xx:xx:xx:xx or xx-xx-xx-xx-xx-xx) or empty"
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
