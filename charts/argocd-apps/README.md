# argocd-apps chart

Render ArgoCD `Application` resources from Helm values.

## Scope

- Creates `Application` resources only.
- Does not create ArgoCD `AppProject`, repo credentials, RBAC, or namespaces.

## Values contract

- `applications[]` defines the ArgoCD Applications to render.
- Each application entry requires:
  - `name`
  - `source.repoURL`
  - `source.targetRevision`
  - one of `source.path` or `source.chart`
  - `destination.namespace`
- Optional per app:
  - `namespace` (metadata namespace for the `Application`; defaults to `defaults.namespace`)
  - `project`, `labels`, `annotations`
  - `source.helm` block
  - `destination.server`
  - `syncPolicy`, `ignoreDifferences`, `info`, `revisionHistoryLimit`
- `defaults.syncPolicy` is optional:
  - leave it unset to use the chart default automated sync policy
  - set it to `null` to omit `spec.syncPolicy` unless an app defines its own `syncPolicy`

## Install

```bash
helm upgrade --install argocd-apps ./charts/argocd-apps -n argocd
```

## Examples

- `examples/minimal.yaml`
- `examples/helm-repo-chart.yaml`
- `examples/no-default-sync-policy.yaml`
- `examples/no-default-sync-policy.yaml` shows how to preserve apps that intentionally omit `spec.syncPolicy`
- `examples/invalid-duplicate-name.yaml`
