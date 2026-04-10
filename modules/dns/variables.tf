variable "zone_id" {
  type        = string
  description = "Cloudflare DNS zone identifier"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod)"
}

variable "dns_records" {
  type = map(object({
    type    = string
    content = string
    ttl     = optional(number, 300)
    proxied = optional(bool, false)
  }))
  default     = {}
  description = "Map of DNS record names to their configuration"
}
