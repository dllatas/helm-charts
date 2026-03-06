# tekton-ci chart

Environment-agnostic Tekton CI bundle chart for webhook-driven image builds.

## Resources rendered

- `Pipeline`
- `TriggerBinding` (optional creation)
- `TriggerTemplate` (optional creation)
- `EventListener` (single listener or per-trigger listeners)
- `HTTPRoute` (optional)

## Not included in this chart

- Namespace, service account, RBAC
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
- `eventListener.mode: perTrigger`
  - one EventListener per trigger

## Trigger model

Each entry in `triggers[]` defines one webhook trigger:

- `name`
- `repoFullName`
- `image.reference`, `image.dockerfile`, `image.context`
- `pathFilters[]`
- optional `extraCelFilters[]`

## HTTPRoute

Enable with `httpRoute.enabled: true`.

- single mode: one path prefix (`httpRoute.pathPrefix`) to one listener backend
- per-trigger mode: one rule per trigger; route path defaults to `/<trigger-name>/`
  - override per trigger via `httpRoute.routePathPrefixByTrigger.<triggerName>`

## Examples

- `examples/single-listener.yaml`
- `examples/per-trigger.yaml`
- `examples/api-v1.yaml`
- `examples/invalid-duplicate-trigger.yaml`
- `examples/invalid-missing-path.yaml`
