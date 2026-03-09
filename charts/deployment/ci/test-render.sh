#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/deployment"

helm lint --strict "$CHART_DIR"
helm template deployment-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/deployment-minimal.yaml"

grep -q '^kind: Deployment$' "/tmp/deployment-minimal.yaml"

if helm template deployment-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/deployment-invalid.yaml" 2>"/tmp/deployment-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "deployment render tests passed"
