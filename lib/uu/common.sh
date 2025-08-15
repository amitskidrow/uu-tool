#!/usr/bin/env bash

# Common helpers: usage, logging, tooling, paths, prompts

usage() {
  cat <<USAGE
${SCRIPT_NAME} v${VERSION}
Make-only bootstrap for a uv-based Python *module directory*.

Usage:
  ${SCRIPT_NAME} <module-dir | module-file.py> [options]

Options:
  --service NAME       Override service name (default: sanitized module dir name)
  --entry CMD          Override entry command (default: python main.py, or python <file.py> if a .py path was provided)
  --makefile-out FILE  Makefile to write/update in the module dir (default: Makefile)
  --readme-out FILE    README to write/update in the module dir (default: README.md)
  --mk-only            Only write the Makefile block
  --readme-only        Only write the README block
  --dry-run            Preview changes; do not write
  --yes                Non-interactive (assume yes)
  -h, --help           Show this help
USAGE
}

fail() { echo "[ERR] $*" >&2; exit 5; }
info() { echo "[..] $*" >&2; }
ok()   { echo "[OK] $*" >&2; }
warn() { echo "[!!] $*" >&2; }

need_tool() {
  command -v "$1" >/dev/null 2>&1 || { echo "[ERR] Required tool not found: $1" >&2; exit 3; }
}

abs_dir() {
  local p="$1"
  if [[ -d "$p" ]]; then
    if command -v readlink >/dev/null 2>&1; then readlink -f "$p" 2>/dev/null || (cd "$p" && pwd -P); else (cd "$p" && pwd -P); fi
  else
    local d; d=$(dirname -- "$p")
    if command -v readlink >/dev/null 2>&1; then printf '%s/%s' "$(readlink -f "$d" 2>/dev/null || (cd "$d" && pwd -P))" "$(basename -- "$p")"; else printf '%s/%s' "$(cd "$d" && pwd -P)" "$(basename -- "$p")"; fi
  fi
}

confirm() {
  (( YES )) && return 0
  read -r -p "$* [y/N] " ans || true
  case "$ans" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

