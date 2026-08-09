#!/usr/bin/env sh
set -eu

INPUT_VER="${1:-lts}"

if [ "${INPUT_VER}" = "lts" ] || [ -z "${INPUT_VER}" ]; then
  RESOLVED_VER=$(curl -sfL "https://api.adoptium.net/v3/info/available_releases" 2>/dev/null | jq -r '.most_recent_lts // empty' 2>/dev/null || true)
  if [ -z "${RESOLVED_VER}" ] || [ "${RESOLVED_VER}" = "null" ]; then
    RESOLVED_VER="21"
  fi
else
  RESOLVED_VER="${INPUT_VER}"
fi

echo "JAVA_MAJOR=${RESOLVED_VER}"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "JAVA_MAJOR=${RESOLVED_VER}" >> "${GITHUB_OUTPUT}"
fi
