# Lobster Trap: Containerizing OpenClaw from Local to K8s and Back

A hands-on demo and tutorial for running [OpenClaw](https://github.com/openclaw/openclaw) AI agents in containers — from a local Docker/Podman setup, through Kubernetes, and back again.

## What you'll learn

1. Why running AI agents in containers matters — isolation, reproducibility, and **team distribution**
2. How to run OpenClaw locally with Docker or Podman
3. How to switch from the upstream local setup to an installer-managed local setup with curated customizations
4. How to use Podman secrets for a clean local developer setup
5. How to switch to Kubernetes Secrets with the [OpenClaw Installer](https://github.com/sallyom/openclaw-installer)
6. How to fan a curated agent baseline out to a team and move back to local when needed

Optional advanced topic:

- how we later got Vault working for Kubernetes SecretRefs with custom installer/runtime glue

## Prerequisites

- [Podman](https://podman.io/docs/installation) (rootless mode)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) (Kubernetes in Docker/Podman)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)
- [OpenClaw CLI](https://docs.openclaw.ai/install) installed on the host
- An API key for at least one model provider (Anthropic, OpenAI, etc.)

Optional for the self-hosted Gemma add-on:

- [Tailscale](https://tailscale.com/) on the demo laptop
- a model endpoint reachable at a stable Tailscale address

## Demo Setup

```bash
# 0. Create the Kind cluster with the upstream script
cd "$PWD/openclaw"
./scripts/k8s/create-kind.sh --name lobster-trap

# 1. Follow the tutorial steps in order
#    01-local-podman.md    → Upstream Podman baseline
#    02-secrets-setup.md   → Installer local + Podman secrets
#    03-deploy-k8s.md      → Deploy to K8s with installer-managed K8s Secrets, then fan out
#    04-and-back.md        → Back to local with the same curated baseline
#    demos/software-qa-mcp → Curated local/K8s agent bundle used in the installer
#
#    Optional appendix:
#    generate-kube-appendix.md → Background on why "container -> K8s YAML" is not the real story here
#    Vault scripts         → Advanced add-on, not the default demo path

# 2. Clean up when done
./scripts/k8s/create-kind.sh --name lobster-trap --delete
```

Optional Gemma add-on for both local and Kind/K8s recording paths:

```bash
# If you already have a model exposed on localhost:8000, publish it on your tailnet
tailscale serve --bg --tcp 8000 127.0.0.1:8000

# Example demo endpoint used in the docs below
# http://100.76.40.32:8000/v1
#
# Turn it off later with:
# tailscale serve --tcp=8000 off
```

## Repository layout

```
lobster-trap-demo/
├── README.md                    # You are here
├── 01-local-podman.md           # Act 1: Run OpenClaw locally with Podman
├── 02-secrets-setup.md          # Act 2: Installer local + Podman secrets
├── 03-deploy-k8s.md             # Act 3/4: Deploy to K8s with installer-managed K8s Secrets, then fan out
├── 04-and-back.md               # Act 4: Back to local
├── generate-kube-appendix.md    # Optional appendix: podman generate kube bridge
├── RECORDING-CHECKLIST.md       # Printable recording script
├── scripts/
│   ├── setup-kind.sh            # Convenience wrapper around Kind setup
│   ├── setup-vault.sh           # Advanced: install Vault via Helm
│   ├── seed-vault-secrets.sh    # Advanced: populate secrets in Vault
│   ├── repair-vault.sh          # Advanced: reapply Vault auth + reseed secrets + restart OpenClaw
│   └── teardown.sh              # Convenience cleanup
├── demos/
│   └── software-qa-mcp/         # Curated agent bundle for installer local/K8s demos
├── config/
│   ├── vault-policy.hcl         # Advanced: Vault policy for OpenClaw
│   └── kind-config.yaml         # Kind cluster configuration
├── Dockerfile.openclaw-vault    # Advanced: demo image layer that installs Vault CLI
└── slides/
    ├── gamma-prompts-local-to-k8s.md # Gamma prompts for the slide deck
    └── speaker-notes.md         # Talking points and timing cues
```

## Summary

| | Local (Podman) | Kubernetes |
|---|---|---|
| **Runtime** | `podman run` | `kubectl apply` / installer |
| **Secrets backend** | Podman secrets | Kubernetes Secrets |
| **Secret injection** | `--secret ... type=env` | `secretKeyRef` -> `env/default/...` SecretRefs |
| **Curated agent setup** | Same | Same |
| **Optional self-hosted model** | Shared Tailscale endpoint | Shared Tailscale endpoint |

The curated agent setup stays the same. The runtime-specific secret plumbing changes.

Vault as an external secrets provider is an advanced add-on.

## Links

- [OpenClaw](https://github.com/openclaw/openclaw)
- [OpenClaw Installer](https://github.com/sallyom/openclaw-installer)
- [OpenClaw Podman docs](https://docs.openclaw.ai/install/podman)
- [OpenClaw Secrets Management](https://docs.openclaw.ai/gateway/secrets)
