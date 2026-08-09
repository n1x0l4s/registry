#!/usr/bin/env sh
set -eu

JAVA_MAJOR="${1:-21}"
JAVA_TYPE="${2:-jre}"
EXPLICIT_MODULES="${3:-}"

DEFAULT_MODULES="java.base,java.logging,java.sql,java.naming,java.management,java.security.jgss,java.instrument,java.rmi,java.xml,java.net.http,jdk.unsupported,jdk.crypto.ec,jdk.crypto.cryptoki"
TARGET_MODULES="${EXPLICIT_MODULES:-$DEFAULT_MODULES}"


echo "Fetching available JDK ${JAVA_MAJOR} modules..." >&2

if command -v java >/dev/null 2>&1 && java -version 2>&1 | grep -q "${JAVA_MAJOR}"; then
  AVAILABLE_MODULES=$(java --list-modules | cut -d'@' -f1)
else
  AVAILABLE_MODULES=$(docker run --rm --net=none "eclipse-temurin:${JAVA_MAJOR}-jdk" java --list-modules | cut -d'@' -f1)
fi

VALIDATED_MODULES=""

OLD_IFS="$IFS"
IFS=','
set -- $TARGET_MODULES
IFS="$OLD_IFS"

for mod in "$@"; do
  # Trim whitespace
  mod=$(echo "$mod" | tr -d ' \t\r\n')
  [ -z "$mod" ] && continue

  if echo "$AVAILABLE_MODULES" | grep -qx "$mod"; then
    if [ -z "$VALIDATED_MODULES" ]; then
      VALIDATED_MODULES="$mod"
    else
      VALIDATED_MODULES="${VALIDATED_MODULES},$mod"
    fi
  else
    echo "WARNING: Module '$mod' is not provided by Temurin JDK ${JAVA_MAJOR} (skipping)." >&2
  fi
done

if [ -z "$VALIDATED_MODULES" ]; then
  echo "ERROR: No valid modules found for Temurin JDK ${JAVA_MAJOR}." >&2
  exit 1
fi

echo "Resolved JAVA_MODULES: ${VALIDATED_MODULES}" >&2

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "JAVA_MODULES=${VALIDATED_MODULES}" >> "${GITHUB_OUTPUT}"
fi
