# role-binding chart

Minimal Helm v4 chart for creating Kubernetes `RoleBinding` resources.

## Scope

- Creates namespaced `RoleBinding` resources only.
- Does not create `Role`, `ClusterRole`, or service accounts.

## Values contract

Required:

- `roleBindings[]`
- `roleBindings[].name`
- `roleBindings[].namespace`
- `roleBindings[].subjects[]`
- `roleBindings[].roleRef`

Optional per role binding:

- `labels`
- `annotations`

## Validation guards

Template-time `fail` checks reject duplicate `name + namespace` pairs.

## Examples

- `examples/minimal.yaml`
- `examples/invalid-duplicate-name.yaml`
