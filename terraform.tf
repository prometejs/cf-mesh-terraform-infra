terraform {
  required_version = ">= 1.8.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.17"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "s3" {
    bucket       = var.aws_s3_bucket
    key          = var.aws_s3_bucket_key
    use_lockfile = var.aws_s3_enable_lockfile
    region       = var.aws_region
    encrypt      = var.aws_s3_bucket_data_encrypt
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
