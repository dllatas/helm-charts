# Changelog

## 0.0.1

- Initial public release of the `application` chart.
- Rebuilt chart for Helm v4-compatible workflows.
- Switched to release-based naming conventions with optional overrides.
- Made service generation explicit via `services[]`.
- Removed Ingress support and added HTTPRoute-focused routing model.
- Added strict values schema and template guard validations.
