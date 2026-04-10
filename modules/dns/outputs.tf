output "record_ids" {
  value       = { for k, r in cloudflare_dns_record.records : k => r.id }
  description = "Map of DNS record names to their Cloudflare record IDs"
}
