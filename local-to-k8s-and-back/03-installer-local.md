# Installer with Podman Secrets

The OpenClaw installer makes the local setup repeatable without turning the talk into a UI demo.

Use it here to show:

- a reusable local deployment
- a curated agent bundle
- Podman secrets instead of pasted API keys
- multiple named local agents on one machine

## Start the openclaw installer

```bash
git clone https://github.com/sallyom/openclaw-installer.git && cd openclaw-installer
npm install && npm run build && npm run dev
```

Open `http://localhost:3000`.

## Fill in the local deploy form

- `Agent Name`
- `Image`
- `Agent Source Directory`
- provider/model choices
- `Podman secret mappings`

## What the installer generates

For local Podman deploys, the installer handles:

- `--secret ... type=env` flags for mapped Podman secrets
- `env/default/...` SecretRefs for known provider credentials
- a persistent local OpenClaw volume for the instance

## Verify the result

After deploy:

- open the instance
- confirm the expected models appear
- interact with the agent

This is the transition from a stock upstream local run to a reusable local baseline.

