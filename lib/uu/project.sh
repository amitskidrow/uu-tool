#!/usr/bin/env bash

find_project_root() {
  local d="$1"
  while [[ "$d" != "/" ]]; do
    if [[ -f "$d/pyproject.toml" ]]; then echo "$d"; return 0; fi
    d="${d%/*}"
  done
  return 1
}

