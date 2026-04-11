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

variable "site_cidrs" {
  type        = map(string)
  description = "Map of site names to their CIDR blocks"
}

variable "allowed_emails" {
  type        = list(string)
  default     = []
  description = "Email addresses allowed access via Zero Trust policies"
}

variable "allowed_email_domains" {
  type        = list(string)
  default     = []
  description = "Email domains allowed access via Zero Trust policies"
}

variable "user_email_domain" {
  type        = string
  description = "Email domain suffix used to match users for the primary device profile (e.g. prometejs.com)"
}
