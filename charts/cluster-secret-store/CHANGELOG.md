# Changelog

## 0.0.3

- Defaulted the chart to `external-secrets.io/v1`.
- Kept `external-secrets.io/v1beta1` as an explicit override for compatibility.

## 0.0.2

- Republished the `cluster-secret-store` chart after the original master publish was blocked by a CI validation failure in unrelated charts.

## 0.0.1

- Initial public release of the `cluster-secret-store` chart.
- Added thin-wrapper rendering for ClusterSecretStore resources.
- Added strict schema validation and duplicate-name guards.
