variable "account_id" {
  type        = string
  description = "Cloudflare account identifier"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, test, prod). Used to derive the VNet name."
}

variable "comment" {
  type        = string
  default     = ""
  description = "Optional free-text comment shown in the Cloudflare UI. Defaults to a derived string."
}

variable "is_default" {
  type        = bool
  default     = false
  description = "Whether this VNet is the account-level default. Only one VNet per account may be default; leave false unless this workspace owns the canonical mesh."
}
