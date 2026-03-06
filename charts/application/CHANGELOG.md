# Changelog

## 3.0.1

- Release bump to publish the initial `application` chart package to OCI.

## 3.0.0

- Rebuilt chart for Helm v4-compatible workflows.
- Switched to release-based naming conventions with optional overrides.
- Made service generation explicit via `services[]`.
- Removed Ingress support and added HTTPRoute-focused routing model.
- Added strict values schema and template guard validations.
