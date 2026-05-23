variable "account_id" {
  type        = string
  description = "Cloudflare account identifier"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod)"
}

variable "routes" {
  type = list(object({
    tunnel_id = string
    network   = string
    comment   = optional(string, "")
  }))
  default     = []
  description = "List of tunnel route configurations"
}

variable "virtual_network_id" {
  type        = string
  description = "Cloudflare Virtual Network ID. Every extra route emitted by this module is pinned to it so it shares the workspace's routing namespace."
}