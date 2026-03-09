# Changelog

## 0.0.4

- Replaced `rg` with `grep` in chart render tests so CI does not depend on ripgrep being present in the tools image.

## 0.0.3

- Clarified the `no-default-sync-policy` example in the README.

## 0.0.2

- Allow `defaults.syncPolicy: null` to disable the chart-level default sync policy.
- Preserve apps that intentionally omit `spec.syncPolicy` while keeping the previous default behavior for existing consumers.

## 0.0.1

- Initial public release of `argocd-apps` chart.
- Supports rendering multiple ArgoCD `Application` resources via `applications[]`.
- Includes strict JSON schema and template guard checks.
