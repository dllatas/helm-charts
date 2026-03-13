# helm-charts-ci chart

Bootstrap chart for this repository CI/CD flow on Tekton.

## Resources

- `Pipeline` for validate/publish flow
- `TriggerBinding`
- `TriggerTemplate`
- `EventListener`
- optional `HTTPRoute`

## Behavior

- Validates changed charts on `push` and `pull_request` events against the target branch baseline.
- Publishes changed charts to Harbor OCI only when:
  - event type is `push`
  - target branch matches `publish.targetBranch` (default `master`)
- Uses the exact push SHA range for target-branch publish so branch rebases do not affect what gets published.

## Run Correlation Labels

Generated `PipelineRun` objects carry `harokilabs.com/tekton-run-id: "$(uid)"`.
Tekton propagates PipelineRun labels onto child `TaskRun` objects, and this chart stamps the same label onto the shared workspace PVC template together with `harokilabs.com/tekton-workspace`.

That gives one stable join key across:

- `PipelineRun`
- child `TaskRun`s
- dynamically created workspace PVCs

## Prerequisites

- Tekton Pipelines + Triggers installed
- GitHub webhook secret (`github.secretName`)
- publish secret (`publish.secretName`) with Harbor credentials/target
- `ssh-key` and `docker-credentials` secrets in the target namespace
- `ci/scripts/*` exists in the cloned repository (this repo)

## Install

```bash
helm upgrade --install helm-charts-ci ./charts/helm-charts-ci -n ci
```

Default `pipeline.toolsImage` is `quay.io/helmpack/chart-testing:v3.14.0`.
Default `run.skipE2E` is `true` for in-cluster Tekton runs.
Default `run.workspaceType` is `volumeClaimTemplate`.
Default `run.pvcSize` is `1Gi`.
This chart uses separate Tekton Tasks for clone, validate, and publish, so the checked-out repository must live on a shared PVC-backed workspace.
`emptyDir` is not supported for this chart.
Set `run.storageClassName` when CI workspaces should use a dedicated ephemeral storage class.
Use `run.nodeSelector` / `run.affinity` to keep PVC-backed `PipelineRun` pods on the general-capacity nodes.
Use `eventListener.nodeSelector` / `eventListener.affinity` to keep the always-on EventListener off the small node.

If terminal `PipelineRun` and `TaskRun` objects are retained for a long time, their workspace PVCs accumulate as well.
Plan to prune completed Tekton runs in-cluster; [Tekton Pruner](https://github.com/tektoncd/pruner) is the right follow-up.

## Deploy Flow

### 1) Bootstrap Harbor + publish secret (OpenTofu)

This chart expects a publish secret (`helm-charts-publish` by default) with:

- `harbor_oci_repo`
- `harbor_username`
- `harbor_password`

Provision it using the OpenTofu stack in `/Users/haroki/code/netcup-iac/harbor`:

```bash
cd /Users/haroki/code/netcup-iac/harbor
tofu init
tofu plan
tofu apply
```

### 2) Check required CI secrets

```bash
kubectl -n ci get secret github-secret docker-credentials ssh-key helm-charts-publish
```

### 3) Install/upgrade the pipeline chart

```bash
helm upgrade --install helm-charts-ci /Users/haroki/code/helm-charts/charts/helm-charts-ci -n ci
```

### 4) Verify deployed resources

```bash
kubectl -n ci get pipeline,triggerbinding,triggertemplate,eventlistener,svc,httproute
helm -n ci status helm-charts-ci
```

### 5) Configure GitHub webhook

Configure a repository webhook for `dllatas/helm-charts`:

- URL: `https://build.harokilabs.com/charts/`
- Content type: `application/json`
- Events: `push`, `pull_request`
- Secret: value stored in `github-secret` (`secretToken` key by default)

### 6) Smoke test

Push a small commit (or redeliver webhook) and verify a `PipelineRun` is created:

```bash
kubectl -n ci get pipelinerun --sort-by=.metadata.creationTimestamp
kubectl -n ci logs -f deploy/el-github-helm-charts
```

### 7) Observe chart publish output

Once a `push` to `master` runs, inspect the pipeline logs for `dist/publish-summary.txt` to confirm chart name, version, and OCI digest were emitted.

## Examples

- `examples/default-ci.yaml`
- `examples/no-route.yaml`
- `examples/api-v1.yaml`
- `examples/general-capacity.yaml`
- `examples/pvc-workspace.yaml`
- `examples/invalid-emptydir-workspace.yaml`
- `examples/invalid-missing-repo.yaml`
