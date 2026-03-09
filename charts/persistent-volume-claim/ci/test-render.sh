#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/persistent-volume-claim"

helm lint --strict "$CHART_DIR"
helm template pvc-minimal "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >/tmp/pvc-minimal.yaml
helm template pvc-bound "$CHART_DIR" -f "$CHART_DIR/examples/bound-volume.yaml" >/tmp/pvc-bound.yaml

grep -q '^kind: PersistentVolumeClaim$' /tmp/pvc-minimal.yaml
grep -q '^  volumeName: "restored-vault"$' /tmp/pvc-bound.yaml

if helm template pvc-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-duplicate-name.yaml" >/tmp/pvc-invalid.yaml 2>/tmp/pvc-invalid.err; then
  echo "Expected invalid-duplicate-name.yaml to fail"
  exit 1
fi

echo "persistent-volume-claim render tests passed"
