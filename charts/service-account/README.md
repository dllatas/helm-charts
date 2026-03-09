# service-account chart

Minimal Helm v4 chart for creating Kubernetes `ServiceAccount` resources.

## Scope

- Creates `ServiceAccount` resources only.
- Does not create roles, role bindings, or secrets.

## Values contract

Required:

- `serviceAccounts[]`
- `serviceAccounts[].name`
- `serviceAccounts[].namespace`

Optional per service account:

- `labels`
- `annotations`
- `automountServiceAccountToken`
- `imagePullSecrets[]`
- `secrets[]`

## Validation guards

Template-time `fail` checks reject duplicate `name + namespace` pairs.

## Examples

- `examples/minimal.yaml`
- `examples/invalid-duplicate-name.yaml`
