# external-secrets chart

Minimal Helm v4 chart for creating External Secrets Operator `ExternalSecret` resources.

## Scope

- Creates `ExternalSecret` resources only.
- Does not create `SecretStore`, `ClusterSecretStore`, or the ESO controller.

## Values contract

Top-level:

- `apiVersion`: defaults to `external-secrets.io/v1`; `external-secrets.io/v1beta1` remains available as an explicit override
- `defaults.namespace`
- `defaults.refreshInterval`
- `defaults.labels`, `defaults.annotations`
- `defaults.secretStoreRef`
- `defaults.target.creationPolicy`, `defaults.target.deletionPolicy`

Required per external secret:

- `name`
- `namespace` unless `defaults.namespace` is set
- `secretStoreRef.kind` and `secretStoreRef.name`, unless `defaults.secretStoreRef` is set
- `target.name`
- exactly one of `data` or `dataFrom`

Optional per external secret:

- `refreshInterval`
- `labels`, `annotations`
- `target.creationPolicy`, `target.deletionPolicy`, `target.template`, `target.immutable`

When `apiVersion` is `external-secrets.io/v1`, the chart renders the controller's defaulted `remoteRef` and target template fields explicitly so Argo comparison stays aligned with live objects after reconciliation.

## Validation guards

Template-time `fail` checks reject:

- duplicate `name + namespace` pairs
- entries that set both `data` and `dataFrom`
- entries that set neither `data` nor `dataFrom`

## Examples

- `examples/data.yaml`
- `examples/data-from.yaml`
- `examples/api-v1.yaml`
- `examples/invalid-duplicate-name.yaml`
- `examples/invalid-data-selection.yaml`
