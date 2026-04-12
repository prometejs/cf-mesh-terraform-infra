# --------------------------------------------------------------------------
# Site Connector Modules
# --------------------------------------------------------------------------
# Instantiate one site-connector module per site defined in var.sites.
# Each module creates a WARP Connector tunnel, teamnet route, and private
# DNS hostname route.

module "site" {
  source   = "./modules/site-connector"
  for_each = var.sites

  site_name          = each.key
  site_cidr          = each.value.cidr
  connector_ip       = each.value.connector_ip
  account_id         = var.cloudflare_account_id
  environment        = terraform.workspace
  private_dns_suffix = var.private_dns_suffix
}

# --------------------------------------------------------------------------
# Zero Trust Policies
# --------------------------------------------------------------------------
# Gateway network policies and device profiles for inter-site traffic.

module "zero_trust_policies" {
  source = "./modules/zero-trust-policies"

  account_id        = var.cloudflare_account_id
  zone_id           = var.cloudflare_zone_id
  environment       = terraform.workspace
  site_cidrs        = { for name, site in var.sites : name => site.cidr }
  user_email_domain = var.user_email_domain
}

# --------------------------------------------------------------------------
# Ansible Inventory Resources (cloud.terraform provider)
# --------------------------------------------------------------------------
# These resources define the Ansible dynamic inventory directly in TF state.
# The cloud.terraform.terraform_provider inventory plugin reads them.
#...

resource "ansible_group" "connectors" {
  name = "connectors"
}

resource "ansible_group" "environment" {
  name     = terraform.workspace
  children = [ansible_group.connectors.name]
}

resource "ansible_host" "site" {
  for_each = var.sites

  name   = each.key
  groups = [ansible_group.connectors.name]

  variables = {
    ansible_host     = each.value.connector_ip
    tunnel_token     = module.site[each.key].tunnel_token
    site_cidr        = each.value.cidr
    private_hostname = module.site[each.key].private_hostname
    ha_enabled       = tostring(each.value.ha_enabled)
    ha_peer_ip       = each.value.ha_peer_ip
    environment      = terraform.workspace
    remote_cidrs = jsonencode([
      for k, v in var.sites : v.cidr if k != each.key
    ])
  }
}
