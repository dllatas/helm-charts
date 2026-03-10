#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/job"

helm lint --strict "$CHART_DIR"
helm template job-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/job-minimal.yaml"

grep -q '^kind: Job$' "/tmp/job-minimal.yaml"

helm template job-disabled "$CHART_DIR" -f "$CHART_DIR/examples/disabled.yaml" >"/tmp/job-disabled.yaml"
if grep -q '^kind: Job$' "/tmp/job-disabled.yaml"; then
  echo "Expected disabled.yaml to render no Job"
  exit 1
fi

if helm template job-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/job-invalid.yaml" 2>"/tmp/job-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail for job"
  exit 1
fi

echo "job render tests passed"
