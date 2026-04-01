# redis chart

Redis Helm v4 chart for running a primary instance with optional replicas.

## Scope

- Creates namespaced resources only.
- Uses StatefulSets for both the primary and replica roles.
- Supports persistent or ephemeral storage for each role.
- Supports optional password authentication via generated or existing Secret.

## Rendered resources

- `ServiceAccount` when `serviceAccount.create` is enabled.
- `Secret` when `auth.enabled` is true and `auth.existingSecret` is not set.
- Headless and client `Service` resources for the primary role.
- Headless and client `Service` resources for the replica role when replicas are enabled.
- One primary `StatefulSet`.
- One replica `StatefulSet` when `replica.replicaCount > 0`.

## Values contract

Top-level:

- `image`: Redis container image settings.
- `auth`: optional password authentication settings.
- `redis`: Redis port and runtime argument settings.
- `primary`: primary StatefulSet settings.
- `replica`: replica StatefulSet settings.

## Validation guards

Template-time `fail` checks reject invalid authentication combinations:

- `auth.enabled: true` requires either `auth.password` or `auth.existingSecret`.
- `auth.password` and `auth.existingSecret` cannot be set together.
- `auth.existingSecretPasswordKey` must be set when `auth.existingSecret` is used.

## Examples

- `examples/minimal.yaml`
- `examples/auth.yaml`
- `examples/ephemeral.yaml`
- `examples/invalid-auth.yaml`
