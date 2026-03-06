#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="helm-charts-bootstrap-e2e"
NAMESPACE="ci-e2e"
SECRET_TOKEN="bootstrap-e2e-token"
PORT="18081"

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "missing command: $1" >&2; exit 1; }
}

require kind
require kubectl
require helm
require curl
require openssl

cleanup() {
  if [[ -n "${PF_PID:-}" ]]; then
    kill "$PF_PID" >/dev/null 2>&1 || true
  fi
  kind delete cluster --name "$CLUSTER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

kind create cluster --name "$CLUSTER_NAME" >/dev/null
kubectl create namespace "$NAMESPACE" >/dev/null

kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/previous/v0.70.0/release.yaml >/dev/null
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml >/dev/null
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml >/dev/null

kubectl -n tekton-pipelines rollout status deployment/tekton-pipelines-controller --timeout=240s >/dev/null
kubectl -n tekton-pipelines rollout status deployment/tekton-triggers-controller --timeout=240s >/dev/null
kubectl -n tekton-pipelines rollout status deployment/tekton-triggers-core-interceptors --timeout=240s >/dev/null

kubectl -n "$NAMESPACE" create secret generic github-secret --from-literal=secretToken="$SECRET_TOKEN" >/dev/null
kubectl -n "$NAMESPACE" create secret generic ssh-key --from-literal=ssh-privatekey="dummy" --from-literal=known_hosts="github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI" >/dev/null
kubectl -n "$NAMESPACE" create secret generic docker-credentials --from-literal=config.json='{"auths":{}}' >/dev/null
kubectl -n "$NAMESPACE" create secret generic helm-charts-publish \
  --from-literal=harbor_oci_repo=harbor.example.com/helm-charts \
  --from-literal=harbor_username=dummy \
  --from-literal=harbor_password=dummy >/dev/null

cat > /tmp/helm-charts-ci-e2e-values.yaml <<VALUES
github:
  repositoryFullName: haroki/helm-charts

httpRoute:
  enabled: false
VALUES

helm install helm-charts-bootstrap charts/helm-charts-ci -n "$NAMESPACE" -f /tmp/helm-charts-ci-e2e-values.yaml >/dev/null

kubectl -n "$NAMESPACE" wait --for=condition=available deployment/el-github-helm-charts --timeout=180s >/dev/null
kubectl -n "$NAMESPACE" port-forward service/el-github-helm-charts "$PORT":8080 >/tmp/helm-charts-ci-port-forward.log 2>&1 &
PF_PID=$!
sleep 3

payload='{"ref":"refs/heads/main","repository":{"full_name":"haroki/helm-charts","ssh_url":"git@github.com:haroki/helm-charts.git"},"head_commit":{"id":"1234567890abcdef"},"commits":[{"modified":["charts/application/Chart.yaml"],"added":[],"removed":[]}]}'
signature="sha256=$(printf '%s' "$payload" | openssl dgst -sha256 -hmac "$SECRET_TOKEN" -hex | awk '{print $2}')"

curl -sS -X POST "http://127.0.0.1:${PORT}" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: ${signature}" \
  --data "$payload" >/tmp/helm-charts-ci-webhook-response.json

for i in $(seq 1 40); do
  if kubectl -n "$NAMESPACE" get pipelinerun -o name | grep -q .; then
    echo "helm-charts-ci e2e passed"
    exit 0
  fi
  sleep 2
done

echo "No PipelineRun created after webhook" >&2
kubectl -n "$NAMESPACE" get events --sort-by=.lastTimestamp | tail -n 60 >&2 || true
exit 1
