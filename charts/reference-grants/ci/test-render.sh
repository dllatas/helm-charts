#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/reference-grants"

helm lint --strict "$CHART_DIR"
helm template reference-grants-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/reference-grants-minimal.yaml"

grep -q '^kind: ReferenceGrant$' "/tmp/reference-grants-minimal.yaml"

if helm template reference-grants-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/reference-grants-invalid.yaml" 2>"/tmp/reference-grants-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "reference-grants render tests passed"
