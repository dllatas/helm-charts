#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <chart-name>" >&2
  exit 1
fi

CHART="$1"
CHART_DIR="charts/$CHART"
TMP_DIR="$(mktemp -d "/tmp/${CHART}-validate.XXXXXX")"
KUBECONFORM_LOG="$TMP_DIR/kubeconform.log"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if [[ ! -d "$CHART_DIR" ]]; then
  echo "Missing chart directory: $CHART_DIR" >&2
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "helm command not found" >&2
  exit 1
fi

ensure_kubeconform() {
  if command -v kubeconform >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "kubeconform command not found and curl is unavailable for bootstrap" >&2
    exit 1
  fi

  local os arch version archive_url install_dir archive
  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) arch="amd64" ;;
    arm64|aarch64) arch="arm64" ;;
    *)
      echo "Unsupported architecture for kubeconform bootstrap: $arch" >&2
      exit 1
      ;;
  esac

  version="${KUBECONFORM_VERSION:-v0.6.7}"
  archive_url="https://github.com/yannh/kubeconform/releases/download/${version}/kubeconform-${os}-${arch}.tar.gz"
  install_dir="$TMP_DIR/bin"
  archive="$TMP_DIR/kubeconform.tar.gz"

  mkdir -p "$install_dir"
  curl -fsSL "$archive_url" -o "$archive"
  tar -xzf "$archive" -C "$install_dir" kubeconform
  chmod +x "$install_dir/kubeconform"
  export PATH="$install_dir:$PATH"

  if ! command -v kubeconform >/dev/null 2>&1; then
    echo "Failed to bootstrap kubeconform from $archive_url" >&2
    exit 1
  fi
}

ensure_kubeconform

helm lint --strict "$CHART_DIR"

RENDERED_FILES=()

render_chart() {
  local release="$1"
  local output="$2"
  shift 2
  helm template "$release" "$CHART_DIR" "$@" >"$output"
  RENDERED_FILES+=("$output")
}

render_chart "${CHART}-default" "$TMP_DIR/${CHART}-default.yaml"

if [[ -d "$CHART_DIR/examples" ]]; then
  while IFS= read -r example; do
    base="$(basename "$example")"
    if [[ "$base" == invalid-* ]]; then
      continue
    fi
    render_chart "${CHART}-${base%.yaml}" "$TMP_DIR/${CHART}-${base%.yaml}.yaml" -f "$example"
  done < <(find "$CHART_DIR/examples" -type f -name '*.yaml' | sort)

  while IFS= read -r invalid; do
    base="$(basename "$invalid")"
    if helm template "${CHART}-${base%.yaml}" "$CHART_DIR" -f "$invalid" >"$TMP_DIR/${CHART}-${base%.yaml}.yaml" 2>"$TMP_DIR/${CHART}-${base%.yaml}.err"; then
      echo "Expected failure for $invalid" >&2
      exit 1
    fi
  done < <(find "$CHART_DIR/examples" -type f -name 'invalid-*.yaml' | sort)
fi

if [[ -x "$CHART_DIR/ci/test-render.sh" ]]; then
  "$CHART_DIR/ci/test-render.sh"
fi

kubeconform_common_args=(
  -strict
  -summary
  -schema-location default
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'
)

if ! kubeconform "${kubeconform_common_args[@]}" "${RENDERED_FILES[@]}" >"$KUBECONFORM_LOG" 2>&1; then
  if grep -q "could not find schema for" "$KUBECONFORM_LOG"; then
    echo "kubeconform: missing CRD schemas detected, retrying with ignore-missing-schemas + server dry-run fallback"
    kubeconform "${kubeconform_common_args[@]}" -ignore-missing-schemas "${RENDERED_FILES[@]}"

    if ! command -v kubectl >/dev/null 2>&1; then
      echo "kubectl command not found; required for server dry-run fallback validation" >&2
      exit 1
    fi

    for rendered in "${RENDERED_FILES[@]}"; do
      server_err="$TMP_DIR/$(basename "$rendered").server.err"
      if ! kubectl apply --dry-run=server -f "$rendered" >/dev/null 2>"$server_err"; then
        if grep -q "no matches for kind" "$server_err"; then
          echo "kubectl server dry-run skipped unsupported CRD API on current cluster for $(basename "$rendered")"
          continue
        fi
        cat "$server_err" >&2
        exit 1
      fi
    done
  else
    cat "$KUBECONFORM_LOG" >&2
    exit 1
  fi
fi
