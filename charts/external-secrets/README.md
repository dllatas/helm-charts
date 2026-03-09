# external-secrets chart

Minimal Helm v4 chart for creating External Secrets Operator `ExternalSecret` resources.

## Scope

- Creates `ExternalSecret` resources only.
- Does not create `SecretStore`, `ClusterSecretStore`, or the ESO controller.

## Values contract

Top-level:

- `apiVersion`: `external-secrets.io/v1beta1` or `external-secrets.io/v1`

Required per external secret:

- `name`
- `namespace`
- `secretStoreRef.kind`
- `secretStoreRef.name`
- `target.name`
- exactly one of `data` or `dataFrom`

Optional per external secret:

- `refreshInterval`
- `labels`, `annotations`
- `target.creationPolicy`, `target.deletionPolicy`, `target.template`, `target.immutable`

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
