#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/cronjob"

helm lint --strict "$CHART_DIR"
helm template cronjob-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/cronjob-minimal.yaml"

grep -q '^kind: CronJob$' "/tmp/cronjob-minimal.yaml"

if helm template cronjob-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/cronjob-invalid.yaml" 2>"/tmp/cronjob-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail for cronjob"
  exit 1
fi

echo "cronjob render tests passed"
