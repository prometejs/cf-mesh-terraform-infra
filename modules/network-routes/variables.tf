variable "account_id" {
  type        = string
  description = "Cloudflare account identifier"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod)"
}

variable "tunnel_routes" {
  type = map(object({
    tunnel_id = string
    network   = string
    comment   = optional(string, "")
  }))
  default     = {}
  description = "Map of route names to tunnel route configurations"
}
