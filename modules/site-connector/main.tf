resource "random_password" "tunnel_secret" {
  length  = 64
  special = false
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "connector" {
  account_id    = var.account_id
  name          = "${var.environment}-${var.site_name}"
  config_src    = "cloudflare"
  tunnel_secret = base64encode(random_password.tunnel_secret.result)
}

# Retrieve tunnel token via data source (not exported by the resource in v5)
data "cloudflare_zero_trust_tunnel_cloudflared_token" "connector" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.connector.id
}

resource "cloudflare_zero_trust_tunnel_cloudflared_route" "site_cidr" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.connector.id
  network    = var.site_cidr
  comment    = "${var.site_name} site CIDR (${var.environment})"

  lifecycle {
    create_before_destroy = true
  }
}

# v5: cloudflare_record renamed to cloudflare_dns_record
resource "cloudflare_dns_record" "site_connector" {
  zone_id = var.zone_id
  name    = "${var.site_name}.internal"
  content = var.connector_ip
  type    = "A"
  proxied = false
  ttl     = 300
  comment = "WARP Connector for ${var.site_name} (${var.environment})"
}

# Tag the tunnel as a WARP Connector via API
# The v5 provider exposes tun_type as a read-only attribute on the tunnel resource,
# but doesn't allow setting it at creation time. We use the API to convert.
resource "null_resource" "set_warp_connector_type" {
  triggers = {
    tunnel_id = cloudflare_zero_trust_tunnel_cloudflared.connector.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      curl -s -X PATCH \
        "https://api.cloudflare.com/client/v4/accounts/${var.account_id}/cfd_tunnel/${cloudflare_zero_trust_tunnel_cloudflared.connector.id}" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        --data '{"tunnel_type": "warp_connector"}' \
        || echo "Warning: Failed to set WARP Connector type. Tunnel will function as cloudflared."
    EOT
  }
}
