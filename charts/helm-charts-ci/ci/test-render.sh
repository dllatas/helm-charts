#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/helm-charts-ci"

helm lint --strict "$CHART_DIR"
helm template helm-charts-ci-default "$CHART_DIR" -f "$CHART_DIR/examples/default-ci.yaml" >/tmp/helm-charts-ci-default.yaml
helm template helm-charts-ci-no-route "$CHART_DIR" -f "$CHART_DIR/examples/no-route.yaml" >/tmp/helm-charts-ci-no-route.yaml
helm template helm-charts-ci-v1 "$CHART_DIR" -f "$CHART_DIR/examples/api-v1.yaml" >/tmp/helm-charts-ci-v1.yaml
helm template helm-charts-ci-pvc "$CHART_DIR" -f "$CHART_DIR/examples/pvc-workspace.yaml" >/tmp/helm-charts-ci-pvc.yaml

grep -q 'volumeClaimTemplate:' /tmp/helm-charts-ci-default.yaml
grep -q 'volumeClaimTemplate:' /tmp/helm-charts-ci-pvc.yaml

if helm template helm-charts-ci-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-missing-repo.yaml" >/tmp/helm-charts-ci-invalid.yaml 2>/tmp/helm-charts-ci-invalid.err; then
  echo "Expected invalid-missing-repo.yaml to fail"
  exit 1
fi

if helm template helm-charts-ci-invalid-emptydir "$CHART_DIR" -f "$CHART_DIR/examples/invalid-emptydir-workspace.yaml" >/tmp/helm-charts-ci-invalid-emptydir.yaml 2>/tmp/helm-charts-ci-invalid-emptydir.err; then
  echo "Expected invalid-emptydir-workspace.yaml to fail"
  exit 1
fi

echo "helm-charts-ci render tests passed"
