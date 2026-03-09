# persistent-volume-claim chart

Minimal Helm v4 chart for creating Kubernetes `PersistentVolumeClaim` resources with exact names.

## Scope

- Creates `PersistentVolumeClaim` resources only.
- Does not create pods, volumes, or storage classes.

## Values contract

Required per claim:

- `name`
- `namespace`
- `size`
- `accessModes[]`

Optional per claim:

- `storageClassName`
- `volumeMode`
- `volumeName`
- `labels`, `annotations`

## Validation guards

Template-time `fail` checks reject duplicate `name + namespace` pairs.

## Examples

- `examples/minimal.yaml`
- `examples/bound-volume.yaml`
- `examples/invalid-duplicate-name.yaml`
