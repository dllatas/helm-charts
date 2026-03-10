#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/config-map"

helm lint --strict "$CHART_DIR"
helm template config-map-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/config-map-minimal.yaml"

grep -q '^kind: ConfigMap$' "/tmp/config-map-minimal.yaml"

if helm template config-map-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/config-map-invalid.yaml" 2>"/tmp/config-map-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail for config-map"
  exit 1
fi

echo "config-map render tests passed"
