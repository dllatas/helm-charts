#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/tekton-ci"

helm lint --strict "$CHART_DIR"

helm template tekton-ci-single "$CHART_DIR" -f "$CHART_DIR/examples/single-listener.yaml" >/tmp/tekton-ci-single.yaml
helm template tekton-ci-per "$CHART_DIR" -f "$CHART_DIR/examples/per-trigger.yaml" >/tmp/tekton-ci-per.yaml
helm template tekton-ci-v1 "$CHART_DIR" -f "$CHART_DIR/examples/api-v1.yaml" >/tmp/tekton-ci-v1.yaml
helm template tekton-ci-inline "$CHART_DIR" -f "$CHART_DIR/examples/inline-deploy-netcup-apps.yaml" >/tmp/tekton-ci-inline.yaml

grep -q "branch_slug" /tmp/tekton-ci-single.yaml
grep -q 'storageClassName: "longhorn-ci-ephemeral"' /tmp/tekton-ci-inline.yaml
if grep -q "split('/')\[2\]" /tmp/tekton-ci-single.yaml; then
  echo "Expected branch extraction to preserve slash-named branches"
  exit 1
fi
grep -q '\$(tt.params.branch-slug)-\$(tt.params.git-revision-short)' /tmp/tekton-ci-single.yaml

grep -q 'git config --global --add safe.directory "$(pwd)"' /tmp/tekton-ci-inline.yaml
grep -q 'helm registry login "${DEPLOY_REGISTRY}"' /tmp/tekton-ci-inline.yaml
if grep -q 'resolve_changed_files || true' /tmp/tekton-ci-inline.yaml; then
  echo "Expected inline deploy script to fail fast on git errors"
  exit 1
fi

if helm template tekton-ci-invalid-dup "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-trigger.yaml" >/tmp/tekton-ci-invalid-dup.yaml 2>/tmp/tekton-ci-invalid-dup.err; then
  echo "Expected invalid-duplicate-trigger.yaml to fail"
  exit 1
fi

if helm template tekton-ci-invalid-path "$CHART_DIR" -f "$CHART_DIR/examples/invalid-missing-path.yaml" >/tmp/tekton-ci-invalid-path.yaml 2>/tmp/tekton-ci-invalid-path.err; then
  echo "Expected invalid-missing-path.yaml to fail"
  exit 1
fi

if helm template tekton-ci-invalid-route "$CHART_DIR" -f "$CHART_DIR/examples/invalid-route-map.yaml" >/tmp/tekton-ci-invalid-route.yaml 2>/tmp/tekton-ci-invalid-route.err; then
  echo "Expected invalid-route-map.yaml to fail"
  exit 1
fi

if helm template tekton-ci-invalid-inline-mode "$CHART_DIR" -f "$CHART_DIR/examples/invalid-inline-per-trigger.yaml" >/tmp/tekton-ci-invalid-inline-mode.yaml 2>/tmp/tekton-ci-invalid-inline-mode.err; then
  echo "Expected invalid-inline-per-trigger.yaml to fail"
  exit 1
fi

echo "tekton-ci render tests passed"
