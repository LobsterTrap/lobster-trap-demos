# Act 3: Deploy to Kubernetes with Kubernetes Secrets

## From "works on my machine" to "works for my whole team"

We've been running a single agent on one machine. But what happens when your teammate wants the same setup? Or when you want to give every engineer on your team a pre-configured AI assistant with your team's conventions, tools, and model choices baked in?
What if your team has a shared kubernetes platform with services, registries, and other tools that you access centrally?

OpenClaw documents a dev Kubernetes path in [docs/install/kubernetes.md](https://github.com/openclaw/openclaw/blob/main/docs/install/kubernetes.md), and ships the Kind/bootstrap scripts under [scripts/k8s](https://github.com/openclaw/openclaw/tree/main/scripts/k8s).
In this demo, the installer builds on that and makes the deployment repeatable.

The local setup used Podman secrets with `env/default/...` SecretRefs.
Here, we switch the runtime to Kubernetes with installer-managed `openclaw-secrets`.

`openclaw-secrets` backs these env vars (if provided):

  - ANTHROPIC_API_KEY
  - OPENAI_API_KEY
  - MODEL_ENDPOINT_API_KEY
  - OPENROUTER_API_KEY

And for those known fields, the installer/deployer renders OpenClaw config that uses:

  - env/default/ANTHROPIC_API_KEY
  - env/default/OPENAI_API_KEY
  - env/default/MODEL_ENDPOINT_API_KEY
  - env/default/OPENROUTER_API_KEY

## Start Kind Kubernetes local cluster

[Kind](https://kind.sigs.k8s.io/) is a tool for running a local kubernetes cluster in a container.
It was meant for devs to test kubernetes itself, but it is useful for local testing of applications on k8s, also.

```bash
cd "$PWD/openclaw"
./scripts/k8s/create-kind.sh --name lobster-trap
kubectl config use-context kind-lobster-trap
```

## Start the installer

If it's not running,

```bash
cd openclaw-installer
npm run build && npm run dev
```

Open `http://localhost:3000` in your browser.

## Deploy to Kubernetes

In the installer UI, use default values or modify values as needed. These you need to add values for:

1. **Deploy Target**: Select **Kubernetes**
2. **Model Provider**: Select a Primary Provider
3. **Agent Source Directory**: use the same curated directory you used for the local installer deploy

### Secret handling

Leave **Advanced: External Secret Providers** empty unless you are trying the Vault setup.

The default Kubernetes story here is:

- the installer writes the provider keys into the managed Kubernetes `Secret` named `openclaw-secrets`
- the pod consumes them via `secretKeyRef`
- OpenClaw uses `env/default/...` SecretRefs inside `openclaw.json`

9. Click **Deploy**

## Watch it come up

The installer streams deployment logs in real-time. Behind the scenes, it creates:

```bash
kubectl get all -n $NAMESPACE
```

You'll see:
- `deployment/openclaw` — the OpenClaw gateway pod
- `service/openclaw` — in-cluster networking
- `configmap/openclaw-config` — your `openclaw.json`
- `secret/openclaw-secrets` — provider keys for runtime env injection
- `pvc/openclaw-home-pvc` — persistent storage for agent state

## Access the agent

From the installer's **Instances** tab:
- Click the instance name
- Click **Open** — the installer starts a managed `kubectl port-forward` and opens the gateway UI

## Verify the default K8s secret path

```bash
kubectl get secret openclaw-secrets -n $NAMESPACE
kubectl logs -n $NAMESPACE deploy/openclaw --tail=50
```

You should see the same setup as local, but now running in a pod with a PVC and K8s Secret-backed env vars.

## Fan out one curated baseline to a team

Now imagine you're a platform engineer. You've built this curated agent — the right model, the right MCP servers, AGENTS.md with your team's coding conventions. You want every developer to have this as their baseline.

- one namespace per teammate
- same curated bundle
- same image
- different `openclaw-secrets` and workspaces
