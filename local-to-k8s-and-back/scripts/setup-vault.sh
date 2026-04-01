#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
NAMESPACE="${VAULT_NAMESPACE:-vault}"
OPENCLAW_AUTH_NAMESPACES="${OPENCLAW_AUTH_NAMESPACES:-openclaw}"

echo "==> Adding HashiCorp Helm repo"
helm repo add hashicorp https://helm.releases.hashicorp.com 2>/dev/null || true
helm repo update hashicorp

echo "==> Installing Vault in dev mode (namespace: ${NAMESPACE})"
kubectl create namespace "${NAMESPACE}" 2>/dev/null || true

helm upgrade --install vault hashicorp/vault \
  --namespace "${NAMESPACE}" \
  --set "server.dev.enabled=true" \
  --set "server.dev.devRootToken=demo-root-token" \
  --set "server.service.type=NodePort" \
  --set "server.service.nodePort=30200" \
  --set "injector.enabled=false" \
  --set "ui.enabled=true" \
  --wait --timeout 120s

echo "==> Waiting for Vault pod to be ready"
kubectl wait --namespace "${NAMESPACE}" \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=vault \
  --timeout=120s

echo "==> Enabling Kubernetes auth method in Vault"
kubectl exec -n "${NAMESPACE}" vault-0 -- vault auth enable kubernetes 2>/dev/null || true

kubectl exec -n "${NAMESPACE}" vault-0 -- sh -c '
  vault write auth/kubernetes/config \
    kubernetes_host="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}"
'

echo "==> Applying OpenClaw Vault policy"
kubectl cp "${REPO_DIR}/config/vault-policy.hcl" "${NAMESPACE}/vault-0:/tmp/vault-policy.hcl"
kubectl exec -n "${NAMESPACE}" vault-0 -- vault policy write openclaw /tmp/vault-policy.hcl

echo "==> Creating Vault role for OpenClaw (namespaces: ${OPENCLAW_AUTH_NAMESPACES}, service account: openclaw)"

kubectl exec -n "${NAMESPACE}" vault-0 -- vault write auth/kubernetes/role/openclaw \
  bound_service_account_names=openclaw \
  bound_service_account_namespaces="${OPENCLAW_AUTH_NAMESPACES}" \
  policies=openclaw \
  ttl=24h

echo ""
echo "==> Vault is ready."
echo "    Dev root token: demo-root-token"
echo "    In-cluster:     http://vault.${NAMESPACE}.svc:8200"
echo "    From host:      http://localhost:8200 (via Kind NodePort)"
echo ""
echo "    Next: ./scripts/seed-vault-secrets.sh"
