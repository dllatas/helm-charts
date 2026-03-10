# Changelog

## 0.0.2

- Added `deploymentNameOverride` for exact deployment naming.
- Added `resourceNameStrategy` to support exact `Service` and PVC names.
- Added `selectorLabels` to preserve existing label selectors during adoption-heavy migrations.
- Added `global` passthrough so the chart can be used safely as a dependency.
- Added render coverage for exact-name and selector-preserving scenarios.

## 0.0.1

- Initial public release of the `application` chart.
- Rebuilt chart for Helm v4-compatible workflows.
- Switched to release-based naming conventions with optional overrides.
- Made service generation explicit via `services[]`.
- Removed Ingress support and added HTTPRoute-focused routing model.
- Added strict values schema and template guard validations.
