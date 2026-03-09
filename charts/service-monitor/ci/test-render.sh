#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/service-monitor"

helm lint --strict "$CHART_DIR"
helm template service-monitor-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/service-monitor-minimal.yaml"

grep -q '^kind: ServiceMonitor$' "/tmp/service-monitor-minimal.yaml"

if helm template service-monitor-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/service-monitor-invalid.yaml" 2>"/tmp/service-monitor-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "service-monitor render tests passed"
