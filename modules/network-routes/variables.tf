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