#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/instrumentation"

helm lint --strict "$CHART_DIR"
helm template instrumentation-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/instrumentation-minimal.yaml"

grep -q '^kind: Instrumentation$' "/tmp/instrumentation-minimal.yaml"

if helm template instrumentation-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/instrumentation-invalid.yaml" 2>"/tmp/instrumentation-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "instrumentation render tests passed"
