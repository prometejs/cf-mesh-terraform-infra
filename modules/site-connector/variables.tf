variable "site_name" {
  type        = string
  description = "Unique name for this site"
}

variable "site_cidr" {
  type        = string
  description = "CIDR block for the site's local network"
}

variable "connector_ip" {
  type        = string
  description = "IP address of the WARP Connector host on the site network"
}

variable "account_id" {
  type        = string
  description = "Cloudflare account identifier"
}

variable "zone_id" {
  type        = string
  description = "Cloudflare DNS zone identifier"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod)"
}
