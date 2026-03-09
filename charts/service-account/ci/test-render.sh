#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/service-account"

helm lint --strict "$CHART_DIR"
helm template service-account-default "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >/tmp/service-account-default.yaml

if [ "$(grep -c '^kind: ServiceAccount$' /tmp/service-account-default.yaml)" -ne 2 ]; then
  echo "Expected minimal example to render two ServiceAccount resources"
  exit 1
fi

if helm template service-account-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >/tmp/service-account-invalid.yaml 2>/tmp/service-account-invalid.err; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "service-account render tests passed"

grep -q "^secrets:$" /tmp/service-account-default.yaml
