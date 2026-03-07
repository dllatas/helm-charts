#!/usr/bin/env bash
set -euo pipefail

BASE_REF="${BASE_REF:-origin/master}"
HEAD_REF="${HEAD_REF:-HEAD}"
BRANCH_NAME="${BRANCH_NAME:-master}"

if [[ -n "${BASE_SHA:-}" ]]; then
  BASE_REF="$BASE_SHA"
fi

if [[ -n "${HEAD_SHA:-}" ]]; then
  HEAD_REF="$HEAD_SHA"
fi

resolve_ref() {
  local ref="$1"
  local branch=""

  if git rev-parse --verify "${ref}^{commit}" >/dev/null 2>&1; then
    return 0
  fi

  if [[ "$ref" == origin/* ]]; then
    branch="${ref#origin/}"
    git fetch --no-tags origin "refs/heads/${branch}:refs/remotes/origin/${branch}" >/dev/null 2>&1 || true
  elif [[ "$ref" =~ ^[0-9a-f]{7,40}$ ]]; then
    git fetch --no-tags origin "refs/heads/${BRANCH_NAME}:refs/remotes/origin/${BRANCH_NAME}" >/dev/null 2>&1 || true
    git fetch --no-tags origin "+refs/heads/*:refs/remotes/origin/*" >/dev/null 2>&1 || true
    git fetch --no-tags origin "$ref" >/dev/null 2>&1 || true
  else
    git fetch --no-tags origin "refs/heads/${BRANCH_NAME}:refs/remotes/origin/${BRANCH_NAME}" >/dev/null 2>&1 || true
    git fetch --no-tags origin "$ref" >/dev/null 2>&1 || true
  fi

  git rev-parse --verify "${ref}^{commit}" >/dev/null 2>&1
}

if ! resolve_ref "$BASE_REF"; then
  echo "Could not resolve BASE_REF=$BASE_REF" >&2
  if [[ "${STRICT_CHANGED_CHARTS:-false}" == "true" ]]; then
    exit 1
  fi
  find charts -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
  exit 0
fi

if ! resolve_ref "$HEAD_REF"; then
  echo "Could not resolve HEAD_REF=$HEAD_REF" >&2
  if [[ "${STRICT_CHANGED_CHARTS:-false}" == "true" ]]; then
    exit 1
  fi
  find charts -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
  exit 0
fi

git diff --name-only "$BASE_REF...$HEAD_REF" \
  | awk -F/ '$1 == "charts" && $2 != "" {print $2}' \
  | sort -u
