# CI/CD

This directory defines the repo-wide chart validation and publish process.

Repository-owned Pipelines as Code definitions live in `.tekton/` and call these scripts from Tekton in namespace `ci`.

## Scripts

- `scripts/changed-charts.sh`: list changed chart names from git diff.
- `scripts/assert-version-and-changelog.sh`: enforce version bump + changelog update.
- `scripts/validate-chart.sh`: lint, render, negative tests, and kubeconform.
- `scripts/runtime-e2e.sh`: execute chart runtime e2e hook.
- `scripts/run-validation.sh`: run full validation for all changed charts.
- `scripts/publish-charts.sh`: package and push changed charts to Harbor OCI.

## PaC behavior

- `.tekton/helm-charts-pr.yaml`: validate pull requests targeting `master`.
- `.tekton/helm-charts-push.yaml`: validate pushes to `master` and publish only pushes to `master`.
- Both definitions run with `SKIP_E2E=true` in-cluster and keep the shared PVC/node placement used by the legacy `helm-charts-ci` chart.

## PaC prerequisites

- Pipelines as Code must be configured for `dllatas/helm-charts` in namespace `ci`.
- The cluster must provide the `git-clone` task and the `ci-services` service account.
- Harbor publish still requires the `helm-charts-publish` secret with `harbor_oci_repo`, `harbor_username`, and `harbor_password`.
- Repository clone auth now comes from the PaC-generated `{{git_auth_secret}}` workspace secret rather than the legacy repo-specific SSH secret.

## Runtime e2e contract

Every chart must provide an executable file:

```text
ci/e2e/<chart-name>.sh
```

## Tekton bootstrap chart

Legacy repository CI bootstrap resources are still packaged in:

```text
charts/helm-charts-ci
```

Install:

```bash
helm upgrade --install helm-charts-ci ./charts/helm-charts-ci -n ci
```

The bootstrap expects:

- a tools image `ghcr.io/haroki/helm-ci-tools:latest` (or override to your own)
- `github-secret` in namespace `ci`
- `helm-charts-publish` secret with `harbor_oci_repo`, `harbor_username`, `harbor_password`
- `ssh-key` and `docker-credentials` secrets
