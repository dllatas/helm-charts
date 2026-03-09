#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/http-routes"

helm lint --strict "$CHART_DIR"
helm template http-routes-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/http-routes-minimal.yaml"

grep -q '^kind: HTTPRoute$' "/tmp/http-routes-minimal.yaml"

if helm template http-routes-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/http-routes-invalid.yaml" 2>"/tmp/http-routes-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "http-routes render tests passed"
