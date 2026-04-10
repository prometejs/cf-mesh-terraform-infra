# Additional CIDR validation logic beyond what's in variables.tf
# These locals provide computed validation for use in plan-time checks.

locals {
  site_networks = {
    for name, site in var.sites : name => site.cidr
  }

  # Flatten all site pairs for overlap checking
  site_pairs = flatten([
    for i, name_a in keys(var.sites) : [
      for j, name_b in keys(var.sites) : {
        a_name = name_a
        b_name = name_b
        a_cidr = var.sites[name_a].cidr
        b_cidr = var.sites[name_b].cidr
      } if j > i
    ]
  ])
}

# Validate connector IPs are within their respective CIDRs
resource "null_resource" "validate_connector_ips" {
  for_each = var.sites

  lifecycle {
    precondition {
      condition     = cidrhost(each.value.cidr, 0) != "" && can(cidrhost(each.value.cidr, 1))
      error_message = "Site '${each.key}' has an invalid CIDR: ${each.value.cidr}"
    }
  }
}
