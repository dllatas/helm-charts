# cluster-role-binding chart

Minimal Helm v4 chart for creating Kubernetes `ClusterRoleBinding` resources.

## Scope

- Creates cluster-scoped `ClusterRoleBinding` resources only.
- Does not create `ClusterRole`, `Role`, or service accounts.

## Values contract

Required:

- `clusterRoleBindings[]`
- `clusterRoleBindings[].name`
- `clusterRoleBindings[].subjects[]`
- `clusterRoleBindings[].roleRef`

Optional per cluster role binding:

- `labels`
- `annotations`

## Validation guards

Template-time `fail` checks reject duplicate names.

## Examples

- `examples/minimal.yaml`
- `examples/invalid-duplicate-name.yaml`
