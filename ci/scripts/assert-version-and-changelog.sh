#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <chart-name>" >&2
  exit 1
fi

CHART="$1"
CHART_DIR="charts/$CHART"
CHART_YAML="$CHART_DIR/Chart.yaml"
CHANGELOG="$CHART_DIR/CHANGELOG.md"
BASE_REF="${BASE_REF:-origin/main}"

if [[ ! -f "$CHART_YAML" ]]; then
  echo "Missing $CHART_YAML" >&2
  exit 1
fi

if [[ ! -f "$CHANGELOG" ]]; then
  echo "Missing $CHANGELOG (required)" >&2
  exit 1
fi

NEW_VERSION="$(awk '/^version:[[:space:]]*/ {print $2; exit}' "$CHART_YAML")"
if [[ -z "$NEW_VERSION" ]]; then
  echo "Could not parse version from $CHART_YAML" >&2
  exit 1
fi

OLD_CHART_CONTENT="$(git show "$BASE_REF:$CHART_YAML" 2>/dev/null || true)"
if [[ -n "$OLD_CHART_CONTENT" ]]; then
  OLD_VERSION="$(printf '%s\n' "$OLD_CHART_CONTENT" | awk '/^version:[[:space:]]*/ {print $2; exit}')"
  if [[ "$OLD_VERSION" == "$NEW_VERSION" ]]; then
    echo "Chart $CHART changed but version was not bumped ($NEW_VERSION)" >&2
    exit 1
  fi
fi

OLD_CHANGELOG_CONTENT="$(git show "$BASE_REF:$CHANGELOG" 2>/dev/null || true)"
if [[ -n "$OLD_CHANGELOG_CONTENT" ]]; then
  if diff -q <(printf '%s\n' "$OLD_CHANGELOG_CONTENT") "$CHANGELOG" >/dev/null; then
    echo "Chart $CHART changed but CHANGELOG.md was not updated" >&2
    exit 1
  fi
fi
