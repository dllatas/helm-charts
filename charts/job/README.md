# job chart

Minimal Helm v4 chart for creating `Job` resources.

## Scope

- Creates namespaced resources only.
- Uses a thin-wrapper contract: metadata plus free-form `spec`.
- Supports `isEnabled` per job. Disabled entries render nothing.

## Values contract

Top-level:

- `apiVersion`: defaults to `batch/v1`

Required per resource:

- `name`
- `namespace`
- `spec`

Optional per resource:

- `isEnabled` (defaults to `true`)
- `labels`
- `annotations`

## Validation guards

Template-time `fail` checks reject duplicate name + namespace entries.

## Examples

- `examples/minimal.yaml`
- `examples/disabled.yaml`
- `examples/invalid-duplicate-name.yaml`
