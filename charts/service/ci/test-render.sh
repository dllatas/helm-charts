#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/service"

helm lint --strict "$CHART_DIR"
helm template service-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/service-minimal.yaml"

grep -q '^kind: Service$' "/tmp/service-minimal.yaml"

if helm template service-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/service-invalid.yaml" 2>"/tmp/service-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "service render tests passed"
