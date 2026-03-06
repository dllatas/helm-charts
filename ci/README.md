# CI/CD

This directory defines the repo-wide chart validation and publish process.

## Scripts

- `scripts/changed-charts.sh`: list changed chart names from git diff.
- `scripts/assert-version-and-changelog.sh`: enforce version bump + changelog update.
- `scripts/validate-chart.sh`: lint, render, negative tests, and kubeconform.
- `scripts/runtime-e2e.sh`: execute chart runtime e2e hook.
- `scripts/run-validation.sh`: run full validation for all changed charts.
- `scripts/publish-charts.sh`: package and push changed charts to Harbor OCI.

## Runtime e2e contract

Every chart must provide an executable file:

```text
ci/e2e/<chart-name>.sh
```

## Tekton bootstrap chart

Repository CI bootstrap resources are packaged in:

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
