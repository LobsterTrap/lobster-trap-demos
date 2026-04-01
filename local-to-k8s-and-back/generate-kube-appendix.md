# Appendix: From Container to Kubernetes Manifest

**Time: ~3 minutes**

## The bridge

Your OpenClaw agent is running in a Podman container. Kubernetes runs containers. So... can we just *ask Podman* what the Kubernetes version would look like?
That's exactly what `podman generate kube` does.

## Generate the manifest

```bash
podman generate kube openclaw
```

This outputs a Kubernetes Pod (or Deployment) YAML derived from your running container — volumes, ports, env vars, and all.

```bash
# Save it to a file for inspection
podman generate kube openclaw > /tmp/openclaw-generated.yaml
```

## Inspect what we got

```bash
cat /tmp/openclaw-generated.yaml
```

You'll see:
- A `Pod` spec with the OpenClaw image
- Volume mounts for `~/.openclaw`
- Port mappings for the gateway
- Environment variables from the container

## What's missing?

`podman generate kube` gives you a **starting point**, not a production manifest. What it doesn't give you:

- **Secrets** — env vars with API keys are in the YAML as plaintext. That's not how you do K8s.
- **Services** — no `Service` resource for in-cluster networking.
- **PersistentVolumeClaims** — host path mounts don't translate to cloud storage.
- **Health checks** — no liveness/readiness probes.

This is where the gap between "local container" and "production K8s" lives.

## The lesson

`podman generate kube` is great for understanding the *shape* of your workload in Kubernetes terms. But for real deployments, you need tooling that understands both worlds.

That's why we have:
1. **Kubernetes Secrets** — to handle cluster credentials correctly (next act)
2. **The OpenClaw Installer** — to generate production-grade K8s manifests (Act 4)
