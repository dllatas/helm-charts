# storage-class chart

Minimal Helm v4 chart for creating Kubernetes `StorageClass` resources.

## Scope

- Creates cluster-scoped `StorageClass` resources only.
- Does not create PVCs or volumes.

## Values contract

Required:

- `storageClasses[]`
- `storageClasses[].name`
- `storageClasses[].provisioner`

Optional per storage class:

- `labels`
- `annotations`
- `parameters`
- `allowVolumeExpansion`
- `reclaimPolicy`
- `volumeBindingMode`
- `mountOptions`

## Validation guards

Template-time `fail` checks reject duplicate names.

## Examples

- `examples/minimal.yaml`
- `examples/invalid-duplicate-name.yaml`
