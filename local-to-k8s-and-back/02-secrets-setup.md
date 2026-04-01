# Podman Secrets

If running Docker, export the provider env vars that apply to your environment from the ones
listed below to avoid pasting them directly into the installer form. 

## Create podman secrets for OpenClaw SecretRefs

For a local setup, a clean secrets backend option is [podman secrets](https://docs.podman.io/en/latest/markdown/podman-secret.1.html).
Now we'll map podman secrets to [OpenClaw SecretRefs](https://docs.openclaw.ai/gateway/secrets#secretref-contract).

Use whichever of these applies to your local environment

```bash
printf '%s' "$ANTHROPIC_API_KEY" | podman secret create anthropic_api_key -
printf '%s' "$OPENAI_API_KEY" | podman secret create openai_api_key -
printf '%s' "$OPENROUTER_API_KEY" | podman secret create openrouter_api_key -
printf '%s' "$MODEL_ENDPOINT_API_KEY" | podman secret create model_endpoint_api_key -
```

You only do this once per machine. The secrets stay in Podman's local store and are injected at container start.

## How the podman secrets map to OpenClaw SecretRefs

- Podman secrets inject env vars into the container
- the installer renders OpenClaw config using env/default/... SecretRefs for the following:

```
  ANTHROPIC_API_KEY
  OPENAI_API_KEY
  MODEL_ENDPOINT_API_KEY
  OPENROUTER_API_KEY
```

and they lead to SecretRefs like:

```
env/default/ANTHROPIC_API_KEY
env/default/OPENAI_API_KEY
env/default/MODEL_ENDPOINT_API_KEY
env/default/OPENROUTER_API_KEY
```
