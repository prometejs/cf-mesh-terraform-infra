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
  default     = "eu-west-2"
  description = "AWS region for S3 state backend"
}

variable "aws_s3_bucket" {
  type        = string
  default     = "tf-prometejs-state-bucket"
  description = "S3 bucket name for Terraform state storage"
}

variable "aws_s3_bucket_key" {
  type        = string
  default     = "cloudflare-infra/terraform.tfstate"
  description = "S3 bucket key for Terraform state storage"
}

variable "aws_s3_enable_lockfile" {
  type        = bool
  default     = true
  description = "Flag to enable S3 backend state locking using DynamoDB"
}

variable "aws_s3_bucket_data_encrypt" {
  type        = bool
  default     = true
  description = "flag to toggle bucket data encryption"
}

variable "private_dns_suffix" {
  type        = string
  description = "Private DNS suffix for internal site hostnames (e.g. dev.prometejs.network)"
}

variable "user_email_domain" {
  type        = string
  description = "Email domain used to match users for the primary WARP device profile"
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
