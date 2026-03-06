#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <chart-name>" >&2
  exit 1
fi

CHART="$1"
E2E_SCRIPT="ci/e2e/${CHART}.sh"

if [[ ! -x "$E2E_SCRIPT" ]]; then
  echo "Missing mandatory runtime e2e script: $E2E_SCRIPT" >&2
  exit 1
fi

"$E2E_SCRIPT"
