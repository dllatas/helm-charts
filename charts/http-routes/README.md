# http-routes chart

Minimal Helm v4 chart for creating HTTPRoute resources.

## Scope

- Creates namespaced resources only.
- Uses a thin-wrapper contract: metadata plus free-form `spec`.

## Values contract

Top-level:

- `apiVersion`: defaults to `gateway.networking.k8s.io/v1`

Required per resource:

- `name`
- `namespace`
- `spec`

Optional per resource:

- `labels`
- `annotations`

## Validation guards

Template-time `fail` checks reject duplicate name + namespace entries.

## Examples

- `examples/minimal.yaml`
- `examples/invalid-duplicate-name.yaml`
