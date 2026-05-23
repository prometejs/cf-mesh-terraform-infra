variable "account_id" {
  type        = string
  description = "Cloudflare account identifier"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod)"
}

variable "site_peers" { 
  type        = map(list(string))
  description = "Map of destination CIDR to their allowed CIDR blocks."
}
