#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/external-secrets"

helm lint --strict "$CHART_DIR"
helm template external-secrets-data "$CHART_DIR" -f "$CHART_DIR/examples/data.yaml" >/tmp/external-secrets-data.yaml
helm template external-secrets-data-from "$CHART_DIR" -f "$CHART_DIR/examples/data-from.yaml" >/tmp/external-secrets-data-from.yaml
helm template external-secrets-v1 "$CHART_DIR" -f "$CHART_DIR/examples/api-v1.yaml" >/tmp/external-secrets-v1.yaml
helm template external-secrets-defaults "$CHART_DIR" -f "$CHART_DIR/examples/defaults.yaml" >/tmp/external-secrets-defaults.yaml

grep -q '^apiVersion: external-secrets.io/v1$' /tmp/external-secrets-data.yaml
grep -q '^kind: ExternalSecret$' /tmp/external-secrets-data.yaml
grep -q '^        conversionStrategy: Default$' /tmp/external-secrets-data.yaml
grep -q '^        decodingStrategy: None$' /tmp/external-secrets-data.yaml
grep -q '^        metadataPolicy: None$' /tmp/external-secrets-data.yaml
grep -q '^      engineVersion: v2$' /tmp/external-secrets-data.yaml
grep -q '^      mergePolicy: Replace$' /tmp/external-secrets-data.yaml
grep -q '^  dataFrom:$' /tmp/external-secrets-data-from.yaml
grep -q '^apiVersion: external-secrets.io/v1$' /tmp/external-secrets-v1.yaml
grep -q '^  namespace: staging$' /tmp/external-secrets-defaults.yaml
grep -q '^  refreshInterval: "1m"$' /tmp/external-secrets-defaults.yaml
grep -q '^    name: vault-backend$' /tmp/external-secrets-defaults.yaml

if helm template external-secrets-invalid-dupe "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >/tmp/external-secrets-invalid-dupe.yaml 2>/tmp/external-secrets-invalid-dupe.err; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

if helm template external-secrets-invalid-data "$CHART_DIR" -f "$CHART_DIR/examples/invalid-data-selection.yaml" >/tmp/external-secrets-invalid-data.yaml 2>/tmp/external-secrets-invalid-data.err; then
  echo "Expected invalid-data-selection.yaml to fail"
  exit 1
fi

echo "external-secrets render tests passed"
