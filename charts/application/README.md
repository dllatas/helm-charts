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
- `deploymentNameOverride`: override the rendered `Deployment` name directly.
- `resourceNameStrategy`: `prefixed` (default) or `exact` for `Service`, `HTTPRoute`, and PVC names.
- `deploymentStrategy`: optional raw `Deployment.spec.strategy` passthrough. Use `type: Recreate` for single-replica `ReadWriteOnce` workloads.
- `selectorLabels`: override the default selector labels used by the `Deployment` and generated `Service` resources.
- `nodeSelector`, `affinity`, `podAntiAffinity`, and `topologySpreadConstraints`: optional pod-level scheduling controls passed through to `Deployment.spec.template.spec`.
- `global`: ignored by the chart itself, but accepted so the chart can be used as a dependency in composition charts.

Without overrides, the default fullname is based on:

- `<release-name>-<chart-or-nameOverride>` (truncated to 63 chars)

For adoption-heavy cases, combine:

- `deploymentNameOverride`
- `resourceNameStrategy: exact`
- `selectorLabels`

to preserve existing resource names and selectors.

## Values contract

### Scheduling (optional)

`affinity` accepts the Kubernetes affinity object. `podAntiAffinity` is a direct
convenience value for `affinity.podAntiAffinity`; when supplied, it takes
precedence over `affinity.podAntiAffinity`. `topologySpreadConstraints` is an
array passed through to `Deployment.spec.template.spec.topologySpreadConstraints`.
Empty or omitted values render no additional scheduling fields.
The example below assumes the Helm release is named `learner` and the chart's
default name is `application`; its selectors match the chart's default pod
labels (`app.kubernetes.io/name` and `app.kubernetes.io/instance`).

```yaml
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    - topologyKey: kubernetes.io/hostname
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: application
          app.kubernetes.io/instance: learner
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app.kubernetes.io/name: application
        app.kubernetes.io/instance: learner
```

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

Optional per route:

- `labels`
- `annotations`
- `hostnames[]`

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
- `exact-names.yaml`
