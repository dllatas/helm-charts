# Changelog

## 0.3.1

- Docs: clarified that `eventListener.mode=single` is the easiest default for most repositories.

## 0.3.0

- Added `pipeline.mode=inlineDeploy` for webhook-driven deployment of Harbor `argocd-apps` charts from changed values files.
- Added `deploy.*` values contract (`image`, `valuesGlob`, `lockSuffix`, `chartRef`, `defaultNamespace`, `targetBranch`).
- Added lock file validation contract (`chartVersion`, `releaseName`, `namespace`) in inline deploy runtime logic.
- Added optional deploy RBAC rendering (`deploy.rbac.create`) with Role/RoleBinding for ArgoCD `Application` and Helm release secret writes.
- Updated Trigger overlays/bindings to support push + pull_request SHA and branch extraction consistently.
- Added `examples/inline-deploy-netcup-apps.yaml` and `examples/invalid-inline-per-trigger.yaml`.

## 0.2.0

- Added `pipeline.mode` with `imageBuild` (default) and `genericTask` to support non-image CI flows.
- Added shared webhook params (`branchName`, `eventType`, `beforeSha`, `afterSha`) to pipeline/trigger wiring.
- Added `pipeline.genericTask` values for custom taskRef and parameter mapping.
- Relaxed trigger contract so `triggers[].image` is required only for `imageBuild` mode.
- Added `examples/generic-task-netcup-apps.yaml` and generic mode negative test fixture.

## 0.1.1

- Release bump to publish the initial `tekton-ci` chart package to OCI.

## 0.1.0

- Added initial Tekton CI meta-chart.
- Supports Pipeline, TriggerBinding, TriggerTemplate, EventListener, and optional HTTPRoute.
- Added single/per-trigger listener modes and dual Tekton API version support.
- Added strict schema and runtime guard validations.
