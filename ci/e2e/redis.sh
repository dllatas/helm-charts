#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="helm-charts-redis-e2e"
NAMESPACE="redis-e2e"
PASSWORD="redis-e2e-password"

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "missing command: $1" >&2; exit 1; }
}

require kind
require kubectl
require helm

cleanup() {
  kind delete cluster --name "$CLUSTER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

kind create cluster --name "$CLUSTER_NAME" >/dev/null
kubectl create namespace "$NAMESPACE" >/dev/null

helm install redis-e2e charts/redis \
  -n "$NAMESPACE" \
  --set auth.enabled=true \
  --set-string auth.password="$PASSWORD" \
  --set replica.replicaCount=1 \
  --set primary.persistence.enabled=false \
  --set replica.persistence.enabled=false >/dev/null

kubectl -n "$NAMESPACE" rollout status statefulset/redis-e2e-primary --timeout=180s >/dev/null
kubectl -n "$NAMESPACE" rollout status statefulset/redis-e2e-replica --timeout=180s >/dev/null

kubectl -n "$NAMESPACE" exec redis-e2e-primary-0 -- sh -c 'redis-cli --no-auth-warning -a "$REDIS_PASSWORD" SET codex ready' >/dev/null

for i in $(seq 1 30); do
  if [[ "$(kubectl -n "$NAMESPACE" exec redis-e2e-replica-0 -- sh -c 'redis-cli --no-auth-warning -a "$REDIS_PASSWORD" GET codex' 2>/dev/null || true)" == "ready" ]]; then
    echo "redis e2e passed"
    exit 0
  fi
  sleep 2
done

echo "Replica did not observe replicated data" >&2
kubectl -n "$NAMESPACE" get pods,svc,statefulset >&2 || true
exit 1
