#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/namespace"

helm lint --strict "$CHART_DIR"
helm template namespace-default "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >/tmp/namespace-default.yaml

if ! grep -q '^kind: Namespace$' /tmp/namespace-default.yaml; then
  echo "Expected minimal example to render a Namespace"
  exit 1
fi

if helm template namespace-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-protected-name.yaml" >/tmp/namespace-invalid.yaml 2>/tmp/namespace-invalid.err; then
  echo "Expected invalid-protected-name.yaml to fail"
  exit 1
fi

echo "namespace render tests passed"
