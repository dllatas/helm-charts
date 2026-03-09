#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/object-store"

helm lint --strict "$CHART_DIR"
helm template object-store-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/object-store-minimal.yaml"

grep -q '^kind: ObjectStore$' "/tmp/object-store-minimal.yaml"

if helm template object-store-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/object-store-invalid.yaml" 2>"/tmp/object-store-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "object-store render tests passed"
