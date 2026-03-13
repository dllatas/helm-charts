# Changelog

## 0.0.5

- Added pod-level `nodeSelector` and `affinity` support so PVC-backed `application` consumers can pin workloads away from small nodes.
- Added render coverage for scheduling passthrough.

## 0.0.4

- Fixed `HTTPRoute.backendRefs` rendering to honor `resourceNameStrategy: exact`.
- Added render coverage to ensure exact-named routes target exact-named services.

## 0.0.3

- Added optional `deploymentStrategy` passthrough for adoption-safe rollout control.
- Documented `Recreate` strategy for `ReadWriteOnce` single-replica workloads.
- Added render coverage for strategy rendering.

## 0.0.2

- Added `deploymentNameOverride` for exact deployment naming.
- Added `resourceNameStrategy` to support exact `Service`, `HTTPRoute`, and PVC names.
- Added `selectorLabels` to preserve existing label selectors during adoption-heavy migrations.
- Added `global` passthrough so the chart can be used safely as a dependency.
- Added route-level labels and annotations support for `httpRoutes[]`.
- Added render coverage for exact-name and selector-preserving scenarios.

## 0.0.1

- Initial public release of the `application` chart.
- Rebuilt chart for Helm v4-compatible workflows.
- Switched to release-based naming conventions with optional overrides.
- Made service generation explicit via `services[]`.
- Removed Ingress support and added HTTPRoute-focused routing model.
- Added strict values schema and template guard validations.
