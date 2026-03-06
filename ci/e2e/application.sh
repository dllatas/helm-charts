#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="helm-charts-app-e2e"
NAMESPACE="app-e2e"

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

helm install app-e2e charts/application \
  -n "$NAMESPACE" \
  -f charts/application/examples/one-service.yaml >/dev/null

kubectl -n "$NAMESPACE" rollout status deployment/app-e2e-application --timeout=120s >/dev/null

helm upgrade app-e2e charts/application \
  -n "$NAMESPACE" \
  -f charts/application/examples/multi-service.yaml >/dev/null

helm uninstall app-e2e -n "$NAMESPACE" >/dev/null

echo "application e2e passed"
