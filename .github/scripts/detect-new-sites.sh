#!/usr/bin/env bash
# Inspect a binary Terraform plan and report which site-connector modules
# are being created for the first time. Used by both plan and apply
# workflows to gate the phased onboarding flow.
#
# Args:
#   $1 - path to the binary plan file (default: tfplan.binary)
#
# Required env:
#   GITHUB_OUTPUT - provided by GitHub Actions
#
# Outputs (on $GITHUB_OUTPUT):
#   new_sites - space-separated list of new site names (empty when none)
set -euo pipefail

: "${GITHUB_OUTPUT:?GITHUB_OUTPUT must be set}"

plan_file="${1:-tfplan.binary}"

new_sites=$(terraform show -json "$plan_file" | jq -r '
  [
    .resource_changes[]
    | select(
        .type == "cloudflare_zero_trust_tunnel_cloudflared"
        and (.address | startswith("module.site["))
        and (.change.actions | contains(["create"]))
      )
    | (.address | capture("module\\.site\\[\"(?<n>[^\"]+)\"\\]") | .n)
  ] | join(" ")
')

echo "new_sites=${new_sites}" >>"$GITHUB_OUTPUT"
echo "New sites: ${new_sites:-<none>}"
