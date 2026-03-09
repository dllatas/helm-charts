#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/cluster-issuer"

helm lint --strict "$CHART_DIR"
helm template cluster-issuer-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/cluster-issuer-minimal.yaml"

grep -q '^kind: ClusterIssuer$' "/tmp/cluster-issuer-minimal.yaml"

if helm template cluster-issuer-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/cluster-issuer-invalid.yaml" 2>"/tmp/cluster-issuer-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "cluster-issuer render tests passed"
