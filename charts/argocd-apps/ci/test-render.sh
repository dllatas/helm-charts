#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/argocd-apps"

helm lint --strict "$CHART_DIR"

helm template argocd-apps-default "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >/tmp/argocd-apps-default.yaml
helm template argocd-apps-no-sync "$CHART_DIR" -f "$CHART_DIR/examples/no-default-sync-policy.yaml" >/tmp/argocd-apps-no-sync.yaml

if ! rg -q '^  syncPolicy:$' /tmp/argocd-apps-default.yaml; then
  echo "Expected minimal example to render the default syncPolicy"
  exit 1
fi

if rg -q '^  syncPolicy:$' /tmp/argocd-apps-no-sync.yaml; then
  echo "Expected no-default-sync-policy example to omit spec.syncPolicy"
  exit 1
fi

if helm template argocd-apps-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >/tmp/argocd-apps-invalid.yaml 2>/tmp/argocd-apps-invalid.err; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "argocd-apps render tests passed"
