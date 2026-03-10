#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/authorization-policy"

helm lint --strict "$CHART_DIR"
helm template authorization-policy-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/authorization-policy-minimal.yaml"

grep -q '^kind: AuthorizationPolicy$' "/tmp/authorization-policy-minimal.yaml"

if helm template authorization-policy-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/authorization-policy-invalid.yaml" 2>"/tmp/authorization-policy-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail for authorization-policy"
  exit 1
fi

echo "authorization-policy render tests passed"
