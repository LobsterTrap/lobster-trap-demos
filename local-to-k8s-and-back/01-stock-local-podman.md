# Act 1: Run OpenClaw Locally with Podman

## Why containers?

Before we touch anything, let's talk about *why* you'd bother containerizing an AI agent.

- **Isolation** — your agent's tools, dependencies, and filesystem are sandboxed.
- **Reproducibility** — same image, same behavior. No "works on my machine."
- **Portability** — the same container runs on your laptop, your CI, your cluster.
- **Multi-agent safety** — run multiple openclaw agents side-by-side without them stepping on each other.
- **Team distribution** — You've spent hours crafting the perfect agent setup: the right model, the right MCP servers, AGENTS.md with your team's conventions. A container turns that into a deployable artifact you can give to every engineer on your team.

## Start the OpenClaw container

We'll use the OpenClaw Podman setup from the official docs and the upstream image: `ghcr.io/openclaw/openclaw:latest`.

For this demo, use a disposable local state directory so you can delete this cleanly before switching to the installer multi-agent setup.

```bash
export OPENCLAW_CONFIG_DIR="/tmp/demo-openclaw"
export OPENCLAW_WORKSPACE_DIR="$OPENCLAW_CONFIG_DIR/workspace"
```

First, the one-time setup:

```bash
# Clone OpenClaw (if you haven't already)
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# Follow the upstream Podman docs and write into the demo-local state dir
OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:latest ./scripts/podman/setup.sh
```

Launch with onboarding:

```bash
OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:latest ./scripts/run-openclaw-podman.sh launch setup
```

This starts a rootless Podman container with:
- Your demo-local state directory bind-mounted at `/home/node/.openclaw`
- Gateway port published on `127.0.0.1:18789`

## Verify it's running

```bash
# Check the container
podman ps --filter name=openclaw

# Check gateway health
export OPENCLAW_CONTAINER=openclaw
openclaw gateway status --deep
```

You should see the gateway running and healthy.

Open `http://127.0.0.1:18789/` and use the token from `$OPENCLAW_CONFIG_DIR/.env` if the setup flow prompts for it.

## Talk to your agent

```bash
export OPENCLAW_CONTAINER=openclaw
openclaw message send "What's 2+2?"
```

**Next we'll switch to the installer and use Podman secrets for a cleaner local developer setup.**

## Reset before Act 2

Remove the openclaw before switching to the installer-managed local setup:

```bash
rm -rf "$OPENCLAW_CONFIG_DIR"
podman rm --force openclaw
```
