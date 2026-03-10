#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/tcp-route"

helm lint --strict "$CHART_DIR"
helm template tcp-route-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/tcp-route-minimal.yaml"

grep -q '^kind: TCPRoute$' "/tmp/tcp-route-minimal.yaml"

if helm template tcp-route-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/tcp-route-invalid.yaml" 2>"/tmp/tcp-route-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail for tcp-route"
  exit 1
fi

echo "tcp-route render tests passed"
