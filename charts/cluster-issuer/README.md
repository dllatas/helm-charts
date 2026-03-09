# cluster-issuer chart

Minimal Helm v4 chart for creating ClusterIssuer resources.

## Scope

- Creates cluster-scoped resources only.
- Uses a thin-wrapper contract: metadata plus free-form `spec`.

## Values contract

Top-level:

- `apiVersion`: defaults to `cert-manager.io/v1`

Required per resource:

- `name`

- `spec`

Optional per resource:

- `labels`
- `annotations`

## Validation guards

Template-time `fail` checks reject duplicate name entries.

## Examples

- `examples/minimal.yaml`
- `examples/invalid-duplicate-name.yaml`
