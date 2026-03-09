#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/external-secrets"

helm lint --strict "$CHART_DIR"
helm template external-secrets-data "$CHART_DIR" -f "$CHART_DIR/examples/data.yaml" >/tmp/external-secrets-data.yaml
helm template external-secrets-data-from "$CHART_DIR" -f "$CHART_DIR/examples/data-from.yaml" >/tmp/external-secrets-data-from.yaml

if ! grep -q '^kind: ExternalSecret$' /tmp/external-secrets-data.yaml; then
  echo "Expected data example to render an ExternalSecret"
  exit 1
fi

if ! grep -q '^  dataFrom:$' /tmp/external-secrets-data-from.yaml; then
  echo "Expected data-from example to render dataFrom"
  exit 1
fi

if helm template external-secrets-invalid-dupe "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >/tmp/external-secrets-invalid-dupe.yaml 2>/tmp/external-secrets-invalid-dupe.err; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

if helm template external-secrets-invalid-data "$CHART_DIR" -f "$CHART_DIR/examples/invalid-data-selection.yaml" >/tmp/external-secrets-invalid-data.yaml 2>/tmp/external-secrets-invalid-data.err; then
  echo "Expected invalid-data-selection.yaml to fail"
  exit 1
fi

echo "external-secrets render tests passed"
