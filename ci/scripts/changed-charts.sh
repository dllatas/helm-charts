#!/usr/bin/env bash
set -euo pipefail

BASE_REF="${BASE_REF:-origin/master}"
HEAD_REF="${HEAD_REF:-HEAD}"

if [[ -n "${BASE_SHA:-}" ]]; then
  BASE_REF="$BASE_SHA"
fi

if [[ -n "${HEAD_SHA:-}" ]]; then
  HEAD_REF="$HEAD_SHA"
fi

if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  git fetch origin master >/dev/null 2>&1 || true
fi

if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  find charts -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
  exit 0
fi

git diff --name-only "$BASE_REF...$HEAD_REF" \
  | awk -F/ '/^charts\/[^/]+\// {print $2}' \
  | sort -u
