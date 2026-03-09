#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/cnpg-scheduled-backup"

helm lint --strict "$CHART_DIR"
helm template cnpg-scheduled-backup-positive "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/cnpg-scheduled-backup-minimal.yaml"

grep -q '^kind: ScheduledBackup$' "/tmp/cnpg-scheduled-backup-minimal.yaml"

if helm template cnpg-scheduled-backup-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >"/tmp/cnpg-scheduled-backup-invalid.yaml" 2>"/tmp/cnpg-scheduled-backup-invalid.err"; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "cnpg-scheduled-backup render tests passed"
