#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/cluster-secret-store"

helm lint --strict "$CHART_DIR"
helm template cluster-secret-store-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/cluster-secret-store-minimal.yaml"

grep -q '^apiVersion: external-secrets.io/v1$' "/tmp/cluster-secret-store-minimal.yaml"
grep -q '^kind: ClusterSecretStore$' "/tmp/cluster-secret-store-minimal.yaml"

if helm template cluster-secret-store-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/cluster-secret-store-invalid.yaml" 2>"/tmp/cluster-secret-store-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "cluster-secret-store render tests passed"
