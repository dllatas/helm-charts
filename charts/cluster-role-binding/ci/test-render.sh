#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/cluster-role-binding"

helm lint --strict "$CHART_DIR"
helm template cluster-role-binding-default "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >/tmp/cluster-role-binding-default.yaml

if [ "$(grep -c '^kind: ClusterRoleBinding$' /tmp/cluster-role-binding-default.yaml)" -ne 2 ]; then
  echo "Expected minimal example to render two ClusterRoleBinding resources"
  exit 1
fi

if helm template cluster-role-binding-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >/tmp/cluster-role-binding-invalid.yaml 2>/tmp/cluster-role-binding-invalid.err; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "cluster-role-binding render tests passed"
