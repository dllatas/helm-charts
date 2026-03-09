#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/role-binding"

helm lint --strict "$CHART_DIR"
helm template role-binding-default "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >/tmp/role-binding-default.yaml

if [ "$(grep -c '^kind: RoleBinding$' /tmp/role-binding-default.yaml)" -ne 2 ]; then
  echo "Expected minimal example to render two RoleBinding resources"
  exit 1
fi

if helm template role-binding-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >/tmp/role-binding-invalid.yaml 2>/tmp/role-binding-invalid.err; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "role-binding render tests passed"
