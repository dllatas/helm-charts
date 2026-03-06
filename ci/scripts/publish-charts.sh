#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

: "${HARBOR_OCI_REPO:?HARBOR_OCI_REPO is required, e.g. harbor.harokilabs.com/helm-charts or oci://harbor.harokilabs.com/helm-charts}"
: "${HARBOR_USERNAME:?HARBOR_USERNAME is required}"
: "${HARBOR_PASSWORD:?HARBOR_PASSWORD is required}"

REPO_PATH="${HARBOR_OCI_REPO#oci://}"
REGISTRY_HOST="${REPO_PATH%%/*}"

mapfile -t CHARTS < <(ci/scripts/changed-charts.sh)

if [[ ${#CHARTS[@]} -eq 0 ]]; then
  echo "No changed charts to publish"
  exit 0
fi

mkdir -p dist
: > dist/publish-summary.txt

helm registry login "$REGISTRY_HOST" --username "$HARBOR_USERNAME" --password "$HARBOR_PASSWORD"

for chart in "${CHARTS[@]}"; do
  chart_dir="charts/$chart"
  helm package "$chart_dir" --destination dist
  pkg="$(ls -t dist/${chart}-*.tgz | head -n1)"
  push_out="$(helm push "$pkg" "oci://$REPO_PATH")"

  version="$(awk '/^version:[[:space:]]*/ {print $2; exit}' "$chart_dir/Chart.yaml")"
  digest="$(printf '%s\n' "$push_out" | sed -n 's/.*Digest: //p' | head -n1)"

  echo "$chart,$version,$digest" | tee -a dist/publish-summary.txt

done

echo "Published charts summary:"
cat dist/publish-summary.txt
