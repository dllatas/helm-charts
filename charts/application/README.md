# application chart

Environment-agnostic Helm v4 chart for running Kubernetes applications with:

- `Deployment`
- explicit `Service` resources (`services[]`)
- optional Gateway API `HTTPRoute` resources (`httpRoutes[]`)
- optional `PodDisruptionBudget`
- optional `PersistentVolumeClaim` resources

## Design principles

- Uses Helm release conventions by default:
  - resource names derive from `.Release.Name`
  - namespace derives from `.Release.Namespace`
- No provider-specific resources in core chart.
- No Ingress support; use `HTTPRoute` only.
- Explicit service generation (no implicit service creation from container ports).

## Naming

- `nameOverride`: override chart name portion in generated resource names.
- `fullnameOverride`: override the full generated resource name.

Without overrides, the default fullname is based on:

- `<release-name>-<chart-or-nameOverride>` (truncated to 63 chars)

## Values contract

### `containers[]` (required)

Required per container:

- `name`
- `image`

Optional:

- `command`, `args`, `env`, `resources`, `securityContext`, `readinessProbe`, `livenessProbe`, `volumeMounts`, `ports`

Port contract:

- If a port will be exposed by a service, it must be declared in `containers[].ports[]` with a **named port**.

### `services[]` (optional)

Each service is explicit and must define:

- `name`
- `ports[]`

Each `ports[]` entry must include:

- `name`
- `port`
- `targetPort` (**string** that matches a `containers[].ports[].name`)

### `httpRoutes[]` (optional)

Each route must define:

- `name`
- `parentRefs[]`
- `rules[]`

Each backend in `rules[].backendRefs[]` must define:

- `service` (entry from `services[].name`)
- `port` (numeric service port)

## Validation guards

Template-time `fail` checks ensure:

- duplicate container port names are rejected
- services with unknown `targetPort` names are rejected
- HTTPRoute backends with unknown services are rejected
- HTTPRoute backends with service ports not exposed by that service are rejected
- volume mounts referencing unknown PVC names are rejected
- duplicate `services[]`, `httpRoutes[]`, and `persistentVolumeClaims[]` names are rejected

## Quick examples

See `examples/` for tested scenarios:

- `minimal.yaml`
- `one-service.yaml`
- `multi-service.yaml`
- `httproute.yaml`
