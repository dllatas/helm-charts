#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/telemetry"

helm lint --strict "$CHART_DIR"
helm template telemetry-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/telemetry-minimal.yaml"

grep -q '^kind: Telemetry$' "/tmp/telemetry-minimal.yaml"

if helm template telemetry-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/telemetry-invalid.yaml" 2>"/tmp/telemetry-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "telemetry render tests passed"
