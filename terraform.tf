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
    bucket         = "tf-prometejs-state-bucket"
    key            = "cloudflare-infra/terraform.tfstate"
    dynamodb_table = "tf-prometejs-state-lock"
    region         = "eu-central-1"
    encrypt        = true
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
