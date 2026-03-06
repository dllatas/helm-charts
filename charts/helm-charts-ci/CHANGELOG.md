# Changelog

## 0.1.4

- Added `run.skipE2E` (default `true`) and wired it to `SKIP_E2E` in the validate task.
- Prevents in-cluster pipeline failures caused by `kind`-based runtime e2e scripts.

## 0.1.3

- Changed default `pipeline.toolsImage` to `quay.io/helmpack/chart-testing:v3.14.0` (public and pullable from the cluster).
- Added `kubeconform` auto-bootstrap in `ci/scripts/validate-chart.sh` when the binary is not present in the tools image.

## 0.1.2

- Changed default GitHub repository filter to `dllatas/helm-charts`.
- Updated examples and deployment docs to match the default repository filter.

## 0.1.1

- Docs: added explicit step to verify publish summary output from the pipeline logs.

## 0.1.0

- Added bootstrap Tekton chart for this repository CI/CD.
- Includes Pipeline, TriggerBinding, TriggerTemplate, EventListener, and optional HTTPRoute.
- Supports PR validation and main-branch publish flow to Harbor OCI.
