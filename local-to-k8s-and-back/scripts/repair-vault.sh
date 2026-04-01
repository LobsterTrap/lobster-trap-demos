#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

OPENCLAW_NAMESPACE="${OPENCLAW_NAMESPACE:-somalley-ken-openclaw}"
VAULT_NAMESPACE="${VAULT_NAMESPACE:-vault}"
OPENCLAW_AUTH_NAMESPACES="${OPENCLAW_AUTH_NAMESPACES:-$OPENCLAW_NAMESPACE}"
RESTART_OPENCLAW="${RESTART_OPENCLAW:-true}"

echo "==> Repairing Vault bootstrap for namespace(s): ${OPENCLAW_AUTH_NAMESPACES}"

(
  cd "$REPO_DIR"
  VAULT_NAMESPACE="$VAULT_NAMESPACE" \
  OPENCLAW_AUTH_NAMESPACES="$OPENCLAW_AUTH_NAMESPACES" \
  ./scripts/setup-vault.sh
)

echo "==> Reseeding OpenClaw provider secrets"
(
  cd "$REPO_DIR"
  VAULT_NAMESPACE="$VAULT_NAMESPACE" \
  ./scripts/seed-vault-secrets.sh
)

if [ "$RESTART_OPENCLAW" = "true" ]; then
  echo "==> Restarting OpenClaw pod in namespace: ${OPENCLAW_NAMESPACE}"
  kubectl delete pod -n "$OPENCLAW_NAMESPACE" -l app=openclaw
fi

echo ""
echo "==> Vault repair complete."
echo "    Namespace repaired: ${OPENCLAW_NAMESPACE}"
echo "    Vault auth namespaces: ${OPENCLAW_AUTH_NAMESPACES}"
echo ""
echo "    If the pod was not restarted automatically, restart it with:"
echo "    kubectl delete pod -n ${OPENCLAW_NAMESPACE} -l app=openclaw"
