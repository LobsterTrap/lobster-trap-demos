#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"

BASE_IMAGE="${BASE_IMAGE:-ghcr.io/openclaw/openclaw:latest}"
OUTPUT_IMAGE="${OUTPUT_IMAGE:-quay.io/sallyom/openclaw:latest}"

# This assumes you have podman farm set up for multi-arch builds
# Just run podman build -t quay.io/sallyom/openclaw:latest -f Dockerfile.openclaw-vault . if no podman farm
podman farm build \
  -t "${OUTPUT_IMAGE}" \
  --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
  -f "${DEMO_DIR}/Dockerfile.openclaw-vault" \
  "${DEMO_DIR}"
