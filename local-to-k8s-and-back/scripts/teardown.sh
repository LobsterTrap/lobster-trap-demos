#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${KIND_CLUSTER_NAME:-lobster-trap}"

echo "==> Stopping local OpenClaw container (if running)"
podman stop openclaw 2>/dev/null || true
podman rm openclaw 2>/dev/null || true

echo "==> Deleting Kind cluster: ${CLUSTER_NAME}"
kind delete cluster --name "${CLUSTER_NAME}" 2>/dev/null || true

echo ""
echo "==> Teardown complete."
