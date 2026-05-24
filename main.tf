# --------------------------------------------------------------------------
# Virtual Network (per workspace / environment)
# --------------------------------------------------------------------------

module "vnet" {
  source = "./modules/virtual-network"

  account_id  = var.cloudflare_account_id
  environment = terraform.workspace
}

# --------------------------------------------------------------------------
# Site Mesh Node + Default Routes
# --------------------------------------------------------------------------

module "nodes" {
  source   = "./modules/site-connector"
  for_each = var.sites

  name               = each.key
  cidr               = each.value.cidr
  connector_ip       = each.value.connector_ip
  account_id         = var.cloudflare_account_id
  environment        = terraform.workspace
  virtual_network_id = module.vnet.id
}

# --------------------------------------------------------------------------
# Gateway Network Policies + Device Profiles
# --------------------------------------------------------------------------

module "zero_trust_policies" {
  source = "./modules/zero-trust-policies"

  account_id  = var.cloudflare_account_id
  environment = terraform.workspace
  site_peers  = local.site_peers
}

# --------------------------------------------------------------------------
# Teamnet Routes (Reserved for extra routes)
# --------------------------------------------------------------------------

module "routes" {
  source = "./modules/network-routes"

  account_id         = var.cloudflare_account_id
  environment        = terraform.workspace
  routes             = var.routes
  virtual_network_id = module.vnet.id
}

# --------------------------------------------------------------------------
# Ansible Inventory Resources (cloud.terraform provider)
# --------------------------------------------------------------------------

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
    ansible_host = each.value.connector_ip
    tunnel_token = module.nodes[each.key].tunnel_token
    site_cidr    = each.value.cidr
    ha_enabled   = tostring(each.value.ha_enabled)
    ha_peer_ip   = each.value.ha_peer_ip
    environment  = terraform.workspace
    remote_cidrs = jsonencode([
      for k, v in var.sites : v.cidr if k != each.key
    ])
    metadata = jsonencode({
      mac = each.value.mac
      location = each.value.location
    })
  }
}
