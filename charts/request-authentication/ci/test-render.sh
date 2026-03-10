#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/request-authentication"

helm lint --strict "$CHART_DIR"
helm template request-authentication-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/request-authentication-minimal.yaml"

grep -q '^kind: RequestAuthentication$' "/tmp/request-authentication-minimal.yaml"

if helm template request-authentication-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/request-authentication-invalid.yaml" 2>"/tmp/request-authentication-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail for request-authentication"
  exit 1
fi

echo "request-authentication render tests passed"
