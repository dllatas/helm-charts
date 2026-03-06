# Changelog

## 0.1.2

- Changed default GitHub repository filter to `dllatas/helm-charts`.
- Updated examples and deployment docs to match the default repository filter.

## 0.1.1

- Docs: added explicit step to verify publish summary output from the pipeline logs.

## 0.1.0

- Added bootstrap Tekton chart for this repository CI/CD.
- Includes Pipeline, TriggerBinding, TriggerTemplate, EventListener, and optional HTTPRoute.
- Supports PR validation and main-branch publish flow to Harbor OCI.
