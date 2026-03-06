#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="helm-charts-tekton-e2e"
NAMESPACE="ci-e2e"
SECRET_TOKEN="e2e-secret-token"
PORT="18080"

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

kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml >/dev/null
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml >/dev/null
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml >/dev/null

kubectl -n tekton-pipelines rollout status deployment/tekton-pipelines-controller --timeout=180s >/dev/null
kubectl -n tekton-pipelines rollout status deployment/tekton-triggers-controller --timeout=180s >/dev/null
kubectl -n tekton-pipelines rollout status deployment/tekton-triggers-core-interceptors --timeout=180s >/dev/null

kubectl -n "$NAMESPACE" create secret generic github-secret --from-literal=secretToken="$SECRET_TOKEN" >/dev/null
kubectl -n "$NAMESPACE" create secret generic ssh-key --from-literal=ssh-privatekey="dummy" --from-literal=known_hosts="github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI" >/dev/null
kubectl -n "$NAMESPACE" create secret generic docker-credentials --from-literal=config.json='{"auths":{}}' >/dev/null

cat > /tmp/tekton-ci-e2e-values.yaml <<VALUES
apiVersions:
  tekton: tekton.dev/v1beta1
  triggers: triggers.tekton.dev/v1beta1
  gateway: gateway.networking.k8s.io/v1

eventListener:
  mode: single
  name: github-listener
  includeChangedFiles: false

github:
  secretName: github-secret
  secretKey: secretToken

triggers:
  - name: app
    repoFullName: org/repo
    image:
      reference: harbor.example.com/project/app
      dockerfile: Dockerfile
      context: .
    pathFilters:
      - "backend/.*"
VALUES

helm install tekton-e2e charts/tekton-ci -n "$NAMESPACE" -f /tmp/tekton-ci-e2e-values.yaml >/dev/null

kubectl -n "$NAMESPACE" wait --for=condition=available deployment/el-github-listener --timeout=180s >/dev/null
kubectl -n "$NAMESPACE" port-forward service/el-github-listener "$PORT":8080 >/tmp/tekton-ci-port-forward.log 2>&1 &
PF_PID=$!
sleep 3

payload='{"ref":"refs/heads/main","repository":{"full_name":"org/repo","ssh_url":"git@github.com:org/repo.git"},"head_commit":{"id":"1234567890abcdef"},"commits":[{"modified":["backend/main.go"],"added":[],"removed":[]}]}'
signature="sha256=$(printf '%s' "$payload" | openssl dgst -sha256 -hmac "$SECRET_TOKEN" -hex | awk '{print $2}')"

curl -sS -X POST "http://127.0.0.1:${PORT}" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: ${signature}" \
  --data "$payload" >/tmp/tekton-ci-webhook-response.json

for i in $(seq 1 30); do
  if kubectl -n "$NAMESPACE" get pipelinerun -o name | grep -q .; then
    echo "tekton-ci e2e passed"
    exit 0
  fi
  sleep 2
done

echo "No PipelineRun created after webhook" >&2
kubectl -n "$NAMESPACE" get events --sort-by=.lastTimestamp | tail -n 40 >&2 || true
exit 1
