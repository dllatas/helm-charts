#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

changed_tmp="$(mktemp)"
if ! ci/scripts/changed-charts.sh >"$changed_tmp"; then
  rm -f "$changed_tmp"
  exit 1
fi
mapfile -t CHARTS <"$changed_tmp"
rm -f "$changed_tmp"

if [[ ${#CHARTS[@]} -eq 0 ]]; then
  echo "No changed charts detected"
  exit 0
fi

echo "Changed charts: ${CHARTS[*]}"

for chart in "${CHARTS[@]}"; do
  echo "==> validating chart: $chart"
  ci/scripts/assert-version-and-changelog.sh "$chart"
  ci/scripts/validate-chart.sh "$chart"

  if [[ "${SKIP_E2E:-false}" != "true" ]]; then
    ci/scripts/runtime-e2e.sh "$chart"
  fi

done

echo "Validation completed"
