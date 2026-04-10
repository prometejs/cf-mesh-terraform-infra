# v5: cloudflare_record renamed to cloudflare_dns_record
resource "cloudflare_dns_record" "records" {
  for_each = var.dns_records

  zone_id = var.zone_id
  name    = each.key
  type    = each.value.type
  content = each.value.content
  ttl     = each.value.ttl
  proxied = each.value.proxied
  comment = "Managed by Terraform (${var.environment})"
}
