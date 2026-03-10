# config-map chart

Minimal Helm v4 chart for creating `ConfigMap` resources.

## Scope

- Creates namespaced resources only.
- Uses a thin contract: metadata plus `data` and optional `binaryData`.

## Values contract

Top-level:

- `configMaps[]`

Required per resource:

- `name`
- `namespace`
- at least one of `data` or `binaryData`

Optional per resource:

- `labels`
- `annotations`
- `immutable`

## Validation guards

Template-time `fail` checks reject duplicate name + namespace entries.

## Examples

- `examples/minimal.yaml`
- `examples/invalid-duplicate-name.yaml`
