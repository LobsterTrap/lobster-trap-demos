# Act 4: Update Paths

## The point

The baseline is not just something you deploy once.

Show how the same curated agent setup can be updated in both environments:

- local for fast iteration
- Kubernetes for shared team use

## Local update path

For the installer-managed local instance:

1. Update the local agent bundle files:
   - `workspace-*`
   - `skills/`
   - `cron/jobs.json`
   - `exec-approvals.json`
2. Re-deploy or restart the local instance from the installer
3. Verify the updated agent behavior in the local UI

This keeps local iteration fast while preserving the same Podman-backed OpenClaw state volume.

### Local backup note

The local OpenClaw state lives in a Podman volume mounted at `/home/node/.openclaw`.

That means you can:

- archive the volume as a recovery backup
- restore it into a new local instance later
- move the state to another machine if needed

The curated bundle is one source of truth. The Podman volume is the runtime state.

## Kubernetes update path

For the installer-managed Kind/Kubernetes instance:

1. Update the same local curated bundle files
2. Re-deploy from the installer
3. Restart the OpenClaw pod if needed
4. Verify the updated agent behavior in the cluster deployment

For this demo, Kubernetes Secrets continue to provide the provider credentials and OpenClaw still reads them through `env/default/...` SecretRefs.

## What comes next

The next step beyond this demo would be GitOps:

- keep the curated bundle in git
- render manifests or installer outputs into a deployable artifact
- let cluster updates flow through pull requests and `kubectl apply` / GitOps controllers

We are not doing that in this demo, but the update path points in that direction.

## Closing thought

Containers are not a one-way door.

The curated agent bundle stays constant. The runtime and secret injection method change.

Update locally when you want speed. Deploy to Kubernetes when you want shared, repeatable team infrastructure.
