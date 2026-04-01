#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CHART_DIR="$ROOT_DIR/charts/redis"

helm lint --strict "$CHART_DIR"
helm template redis-minimal "$CHART_DIR" -f "$CHART_DIR/examples/minimal.yaml" >"/tmp/redis-minimal.yaml"
helm template redis-auth "$CHART_DIR" -f "$CHART_DIR/examples/auth.yaml" >"/tmp/redis-auth.yaml"
helm template redis-ephemeral "$CHART_DIR" -f "$CHART_DIR/examples/ephemeral.yaml" >"/tmp/redis-ephemeral.yaml"

grep -q '^kind: StatefulSet$' "/tmp/redis-minimal.yaml"
grep -q 'app.kubernetes.io/component: "primary"' "/tmp/redis-minimal.yaml"
grep -q 'app.kubernetes.io/component: "replica"' "/tmp/redis-minimal.yaml"
grep -q '^kind: Secret$' "/tmp/redis-auth.yaml"
grep -q -- '--masterauth "${REDIS_PASSWORD}"' "/tmp/redis-auth.yaml"
grep -q 'emptyDir: {}' "/tmp/redis-ephemeral.yaml"

if helm template redis-invalid "$CHART_DIR" -f "$CHART_DIR/examples/invalid-auth.yaml" >"/tmp/redis-invalid.yaml" 2>"/tmp/redis-invalid.err"; then
  echo "Expected invalid-auth.yaml to fail"
  exit 1
fi

echo "redis render tests passed"
