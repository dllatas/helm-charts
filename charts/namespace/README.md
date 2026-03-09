# namespace chart

Minimal Helm v4 chart for creating one Kubernetes `Namespace`.

## Scope

- Creates a single `Namespace` resource.
- Does not create service accounts, quotas, limit ranges, or network policies.

## Values contract

Required:

- `name`

Optional:

- `labels`
- `annotations`
- `finalizers`

## Validation guards

Template-time `fail` checks reject protected namespace names:

- `default`
- `kube-system`
- `kube-public`

## Examples

- `examples/minimal.yaml`
- `examples/invalid-protected-name.yaml`
