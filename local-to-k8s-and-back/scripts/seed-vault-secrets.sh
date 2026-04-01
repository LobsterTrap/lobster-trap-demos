#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${VAULT_NAMESPACE:-vault}"

# Prompt for API keys if not already set
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo -n "Enter your Anthropic API key: "
  read -rs ANTHROPIC_API_KEY
  echo ""
fi

echo "==> Seeding secrets into Vault at secret/openclaw"

put_args=(
  "providers/anthropic/apiKey=${ANTHROPIC_API_KEY}"
)

if [ -n "${OPENAI_API_KEY:-}" ]; then
  put_args+=("providers/openai/apiKey=${OPENAI_API_KEY}")
fi

kubectl exec -n "${NAMESPACE}" vault-0 -- vault kv put secret/openclaw "${put_args[@]}"

echo "==> Verifying secret was stored"
kubectl exec -n "${NAMESPACE}" vault-0 -- sh -ceu '
  payload="$(vault kv get -format=json secret/openclaw)"
  echo "$payload" | grep -q "\"providers/anthropic/apiKey\""
  if echo "$payload" | grep -q "\"providers/openai/apiKey\""; then
    echo "Verified stored keys: providers/anthropic/apiKey, providers/openai/apiKey"
  else
    echo "Verified stored key: providers/anthropic/apiKey"
  fi
'

echo ""
echo "==> Secrets seeded successfully."
echo ""
echo "    To add more provider keys later:"
echo "    kubectl exec -n ${NAMESPACE} vault-0 -- vault kv patch secret/openclaw \\"
echo "      \"providers/openai/apiKey=sk-...\""
echo ""
echo "    Next: follow the tutorial at 01-local-podman.md"
