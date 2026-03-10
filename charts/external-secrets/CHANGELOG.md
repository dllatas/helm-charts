# Changelog

## 0.0.4

- Added `defaults` support for shared namespace, refresh interval, metadata, secret store references, and target policies.

## 0.0.3

- Republished the `external-secrets` chart after the original master publish was blocked by a CI validation failure in unrelated charts.

## 0.0.2

- Added dual API support for `external-secrets.io/v1beta1` and `external-secrets.io/v1`.
- Defaulted the chart to `external-secrets.io/v1beta1` for current cluster compatibility.
- Added API-specific render coverage.

## 0.0.1

- Initial public release of the `external-secrets` chart.
- Added support for `data` and `dataFrom` ExternalSecret patterns.
- Added strict schema validation and duplicate-name guards.
