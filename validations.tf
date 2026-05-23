# Additional CIDR validation logic beyond what's in variables.tf

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

# Validate extra_routes reference defined sites and have valid CIDRs.
# Cross-variable references aren't allowed in variable validation blocks
# pre-1.9, so the checks live here as preconditions.
resource "null_resource" "validate_extra_routes" {
  for_each = { for i, r in var.routes : tostring(i) => r }

  lifecycle {
    precondition {
      condition     = contains(keys(var.sites), each.value.site)
      error_message = "routes['${each.key}']: site '${each.value.site}' is not defined in var.sites."
    }
  }
}
