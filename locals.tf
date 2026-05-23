locals {
  site_peers = {
    for name, site in var.sites :
    site.cidr => (
      site.peers == null
      ? [for other_name, other in var.sites : other.cidr if other_name != name]
      : site.peers
    )
  }
}