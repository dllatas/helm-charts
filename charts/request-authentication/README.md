# request-authentication chart

Minimal Helm v4 chart for creating `RequestAuthentication` resources.

## Scope

- Creates namespaced resources only.
- Uses a thin-wrapper contract: metadata plus free-form `spec`.

## Values contract

Top-level:

- `apiVersion`: defaults to `security.istio.io/v1`

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
