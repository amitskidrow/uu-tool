#!/usr/bin/env bash
set -euo pipefail

file="${1:-Makefile}"

if [[ ! -f "$file" ]]; then
  echo "[ERR] Makefile not found: $file" >&2
  exit 2
fi

pass=true

check() {
  local pattern="$1"; local label="$2"
  if grep -qF -- "$pattern" "$file"; then
    echo "[OK] $label"
  else
    echo "[!!] Missing: $label"; pass=false
  fi
}

check "UU_UNSUFFIXED_DEFINED" "Unsuffixed guard defined"
check "check-service:" "check-service rule present"
check "UU_SERVICES +=" "Service aggregation present"
check "pymon not found; RELOAD=1 requires pymon" "Graceful pymon handling"
check "KEEP_N ?= " "Keep-last-N variable present"
check "LOGDIR    :=" "XDG state LOGDIR present"

$pass && exit 0 || exit 1
