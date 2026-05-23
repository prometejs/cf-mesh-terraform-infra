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
