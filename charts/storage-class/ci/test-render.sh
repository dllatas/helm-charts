#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/storage-class"

helm lint --strict "$CHART_DIR"
helm template storage-class-default "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >/tmp/storage-class-default.yaml

if [ "$(grep -c '^kind: StorageClass$' /tmp/storage-class-default.yaml)" -ne 2 ]; then
  echo "Expected minimal example to render two StorageClass resources"
  exit 1
fi

grep -q 'numberOfReplicas: "1"' /tmp/storage-class-default.yaml

if helm template storage-class-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >/tmp/storage-class-invalid.yaml 2>/tmp/storage-class-invalid.err; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "storage-class render tests passed"
