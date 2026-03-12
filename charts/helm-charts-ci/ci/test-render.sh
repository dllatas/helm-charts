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
grep -q 'storage: 1Gi' /tmp/helm-charts-ci-default.yaml
grep -q 'storageClassName: "longhorn-ci-ephemeral"' /tmp/helm-charts-ci-pvc.yaml
||||||| parent of 6c7b243 (Add Tekton run correlation labels)
grep -q 'harokilabs.com/tekton-run-id: "\$(uid)"' /tmp/helm-charts-ci-default.yaml
grep -q 'harokilabs.com/tekton-workspace: "source"' /tmp/helm-charts-ci-default.yaml
grep -q 'export TARGET_BRANCH="master"' /tmp/helm-charts-ci-default.yaml
grep -q 'export DIFF_MODE="merge-base"' /tmp/helm-charts-ci-default.yaml
grep -q 'export DIFF_MODE="push-range"' /tmp/helm-charts-ci-default.yaml

if helm template helm-charts-ci-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-missing-repo.yaml" >/tmp/helm-charts-ci-invalid.yaml 2>/tmp/helm-charts-ci-invalid.err; then
  echo "Expected invalid-missing-repo.yaml to fail"
  exit 1
fi

if helm template helm-charts-ci-invalid-emptydir "$CHART_DIR" -f "$CHART_DIR/examples/invalid-emptydir-workspace.yaml" >/tmp/helm-charts-ci-invalid-emptydir.yaml 2>/tmp/helm-charts-ci-invalid-emptydir.err; then
  echo "Expected invalid-emptydir-workspace.yaml to fail"
  exit 1
fi

echo "helm-charts-ci render tests passed"
