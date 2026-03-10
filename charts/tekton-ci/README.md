# tekton-ci chart

Environment-agnostic Tekton CI bundle chart for webhook-driven pipelines.

## Resources rendered

- `Pipeline`
- `TriggerBinding` (optional creation)
- `TriggerTemplate` (optional creation)
- `EventListener` (single listener or per-trigger listeners)
- `HTTPRoute` (optional)

## Not included in this chart

- Namespace, service account
- Secrets (`github-secret`, docker creds, ssh creds)
- Tekton task resources (`git-clone`, `buildah`, custom tasks)

## API version support

Set API versions via values:

- `apiVersions.tekton`: `tekton.dev/v1beta1` or `tekton.dev/v1`
- `apiVersions.triggers`: `triggers.tekton.dev/v1beta1` or `triggers.tekton.dev/v1`
- `apiVersions.gateway`: `gateway.networking.k8s.io/v1` (or `v1beta1` if needed)

## Listener modes

- `eventListener.mode: single` (default)
  - one EventListener with many triggers
  - easiest option for most repositories
- `eventListener.mode: perTrigger`
  - one EventListener per trigger

## Pipeline modes

- `pipeline.mode: imageBuild` (default)
  - clone + build/push flow using `taskRefs.clone` and `taskRefs.build`
  - requires `triggers[].image.*`
- `pipeline.mode: inlineDeploy`
  - clone + inline taskSpec deploy flow for Harbor-hosted `argocd-apps` chart
  - validates changed values files and installs on `push` to target branch
  - `triggers[].image.*` not required

## Inline Deploy Contract

When `pipeline.mode=inlineDeploy`:

- changed files are selected by `deploy.valuesGlob` (default `bootstrap/argocd-apps/*.yaml`)
- lock files are required beside each values file using `deploy.lockSuffix` (default `.lock.yaml`)
- each lock file must contain:
  - `chartVersion`
  - `releaseName`
  - `namespace` (falls back to `deploy.defaultNamespace` if empty)
- install executes only when:
  - GitHub event is `push`
  - branch equals `deploy.targetBranch` (default `master`)
- set `deploy.registryAuth.enabled=true` when `deploy.chartRef` points to a private OCI registry

Optional RBAC rendering for deploy mode:

- enable `deploy.rbac.create=true`
- creates Role/RoleBinding in `deploy.rbac.namespace` for applying ArgoCD `Application` resources and Helm release secrets.

Registry auth for private OCI charts:

```yaml
deploy:
  chartRef: oci://harbor.harokilabs.com/helm-charts/argocd-apps
  registryAuth:
    enabled: true
    registry: harbor.harokilabs.com
    secretName: harbor-oci-reader
    usernameKey: username
    passwordKey: password
```

## Trigger model

Each entry in `triggers[]` defines one webhook trigger:

- `name`
- `repoFullName`
- `pathFilters[]`
- optional `extraCelFilters[]`
- `image.reference`, `image.dockerfile`, `image.context` only for `pipeline.mode=imageBuild`
- image tags are derived from a sanitized branch slug; the full branch name is still passed through the pipeline metadata

## Workspace PVCs

- `run.pvcSize` defaults to `1Gi`
- `run.storageClassName` can target a dedicated storage class for ephemeral Tekton workspaces

## HTTPRoute

Enable with `httpRoute.enabled: true`.

- single mode: one path prefix (`httpRoute.pathPrefix`) to one listener backend
- per-trigger mode: one rule per trigger; route path defaults to `/<trigger-name>/`
  - override per trigger via `httpRoute.routePathPrefixByTrigger.<triggerName>`

## Examples

- `examples/single-listener.yaml`
- `examples/per-trigger.yaml`
- `examples/api-v1.yaml`
- `examples/inline-deploy-netcup-apps.yaml`
- `examples/invalid-duplicate-trigger.yaml`
- `examples/invalid-missing-path.yaml`
