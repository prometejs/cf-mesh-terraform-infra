# Retrieve tunnel token via data source (not exported by the resource)
data "cloudflare_zero_trust_tunnel_warp_connector_token" "connector" {
  account_id = var.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_warp_connector.connector.id
}