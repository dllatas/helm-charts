# Changelog

## 0.1.8

- Changed the default shared Tekton workspace binding from `volumeClaimTemplate` to `emptyDir` so CI does not depend on dynamic PVC provisioning.
- Added `run.workspaceType` with `emptyDir` and `volumeClaimTemplate` modes.
- Kept PVC-backed workspaces available as an explicit opt-in with validation and example coverage.

## 0.1.7

- Fixed changed-chart detection strict-mode behavior so ref resolution errors fail tasks instead of silently returning no changes.
- Propagated webhook refs (`base-ref`, `head-ref`, `branch-name`) into publish task to keep validation/publish diff scope aligned.
- Added clone `refspec` to fetch remote branches for reliable SHA-based diff resolution.
- Hardened SHA resolution fallback in `ci/scripts/changed-charts.sh` by fetching branch hints and remote branch refs.

## 0.1.6

- Fixed push event overlays to use GitHub `before`/`after` SHAs for `base_ref`, `head_ref`, and `revision`.
- Added `STRICT_CHANGED_CHARTS=true` in validate/publish tasks to prevent accidental all-chart publish fallback.
- Set `git-clone` depth to `0` for reliable commit-range diffs.
- Hardened `ci/scripts/changed-charts.sh` ref resolution with SHA and branch fetch logic.

## 0.1.5

- Changed default publish branch to `master`.
- Updated EventListener push overlay to emit `base_ref=origin/<publish.targetBranch>` for non-PR events.
- Aligned local CI script base branch defaults to `origin/master`.

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
