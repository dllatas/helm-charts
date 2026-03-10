#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/gateway"

helm lint --strict "$CHART_DIR"
helm template gateway-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/gateway-minimal.yaml"

grep -q '^kind: Gateway$' "/tmp/gateway-minimal.yaml"
grep -q '^  gatewayClassName: istio$' "/tmp/gateway-minimal.yaml"
grep -q '^  listeners:$' "/tmp/gateway-minimal.yaml"

if helm template gateway-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/gateway-invalid.yaml" 2>"/tmp/gateway-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail for gateway"
  exit 1
fi

echo "gateway render tests passed"
