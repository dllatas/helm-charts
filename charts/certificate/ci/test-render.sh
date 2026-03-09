#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/certificate"

helm lint --strict "$CHART_DIR"
helm template certificate-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/certificate-minimal.yaml"

grep -q '^kind: Certificate$' "/tmp/certificate-minimal.yaml"

if helm template certificate-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/certificate-invalid.yaml" 2>"/tmp/certificate-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "certificate render tests passed"
