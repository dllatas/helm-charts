# cronjob chart

Minimal Helm v4 chart for creating `CronJob` resources.

## Scope

- Creates namespaced resources only.
- Uses a thin-wrapper contract: metadata plus free-form `spec`.

## Values contract

Top-level:

- `apiVersion`: defaults to `batch/v1`

Required per resource:

- `name`
- `namespace`
- `spec`
- `spec.schedule`
- `spec.jobTemplate`

Optional per resource:

- `labels`
- `annotations`

## Validation guards

Template-time `fail` checks reject duplicate name + namespace entries.

## Examples

- `examples/minimal.yaml`
- `examples/invalid-duplicate-name.yaml`
