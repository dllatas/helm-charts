# Changelog

## 0.0.2

- Added dual API support for `external-secrets.io/v1beta1` and `external-secrets.io/v1`.
- Defaulted the chart to `external-secrets.io/v1beta1` for current cluster compatibility.
- Added API-specific render coverage.

## 0.0.1

- Initial public release of the `external-secrets` chart.
- Added support for `data` and `dataFrom` ExternalSecret patterns.
- Added strict schema validation and duplicate-name guards.
