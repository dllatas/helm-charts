# helm-charts

Public repository for general-purpose Helm charts that can be composed by private application charts.

## Prerequisites

- Helm v4

## Install Helm v4

Use Helm's official install script:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
```

Recommended (no sudo, user-local install):

```bash
HELM_INSTALL_DIR="$HOME/.local/bin" ./get_helm.sh --version v4.1.1 --no-sudo
helm version --short
```

System-wide install (requires sudo):

```bash
./get_helm.sh --version v4.1.1
helm version --short
```

Expected version format:

```text
v4.x.x+...
```

## Notes

- This repository targets Helm v4 for chart authoring and validation.
- Charts currently included:
  - `charts/application`
  - `charts/argocd-apps`
  - `charts/namespace`
  - `charts/service-account`
  - `charts/role-binding`
  - `charts/cluster-role-binding`
  - `charts/external-secrets`
  - `charts/persistent-volume-claim`
  - `charts/http-routes`
  - `charts/reference-grants`
  - `charts/cluster-secret-store`
  - `charts/cluster-issuer`
  - `charts/certificate`
  - `charts/object-store`
  - `charts/instrumentation`
  - `charts/telemetry`
  - `charts/service-monitor`
  - `charts/deployment`
  - `charts/service`
  - `charts/cnpg-cluster`
  - `charts/cnpg-scheduled-backup`
  - `charts/config-map`
  - `charts/gateway`
  - `charts/request-authentication`
  - `charts/authorization-policy`
  - `charts/tcp-route`
  - `charts/cronjob`
  - `charts/job`
  - `charts/tekton-ci`
  - `charts/helm-charts-ci`

## CI/CD Standard

This repository defines a strict, shared CI/CD process for all charts:

- Detect changed charts.
- Require version bump + changelog update for changed charts.
- `helm lint --strict`.
- Render tests with positive/negative example values.
- `kubeconform` validation.
- Mandatory runtime e2e per chart via `ci/e2e/<chart>.sh`.

Key scripts:

```bash
ci/scripts/changed-charts.sh
ci/scripts/run-validation.sh
ci/scripts/publish-charts.sh
```

Tekton manifest templates for webhook-driven validation/publish flows are under:

```text
ci/tekton/
```

## Deploy Helm Charts CI Pipeline

For the full deployment runbook (Harbor bootstrap with OpenTofu, Helm install, webhook setup, and smoke test), see:

- `charts/helm-charts-ci/README.md`
