#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/cnpg-cluster"

helm lint --strict "$CHART_DIR"
helm template cnpg-cluster-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/cnpg-cluster-minimal.yaml"

grep -q '^kind: Cluster$' "/tmp/cnpg-cluster-minimal.yaml"

if helm template cnpg-cluster-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/cnpg-cluster-invalid.yaml" 2>"/tmp/cnpg-cluster-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "cnpg-cluster render tests passed"
