#!/usr/bin/env bash

# Find the uv project root for a given path, following uv's rules:
# 1) If inside a workspace, return the OUTERMOST ancestor containing [tool.uv.workspace]
# 2) Else, return the NEAREST ancestor containing [project]
# 3) Else, return the NEAREST ancestor containing uv.toml
# 4) Else, fail (non-zero)
find_project_root() {
  local d="$1"

  # Track candidates
  local top_workspace=""      # outermost [tool.uv.workspace]
  local nearest_project=""    # nearest [project]
  local nearest_uvtoml=""     # nearest uv.toml

  # Walk upward to / collecting candidates
  while [[ -n "$d" && "$d" != "/" ]]; do
    if [[ -f "$d/pyproject.toml" ]]; then
      # Outermost workspace: keep updating as we walk upward
      if grep -Eq '^[[:space:]]*\[tool\.uv\.workspace\]' "$d/pyproject.toml"; then
        top_workspace="$d"
      fi
      # Nearest project: set only once (first one we encounter walking upward)
      if [[ -z "$nearest_project" ]] && grep -Eq '^[[:space:]]*\[project\]' "$d/pyproject.toml"; then
        nearest_project="$d"
      fi
    fi
    if [[ -z "$nearest_uvtoml" ]] && [[ -f "$d/uv.toml" ]]; then
      nearest_uvtoml="$d"
    fi
    d="${d%/*}"
  done

  if [[ -n "$top_workspace" ]]; then
    printf '%s\n' "$top_workspace"; return 0
  fi
  if [[ -n "$nearest_project" ]]; then
    printf '%s\n' "$nearest_project"; return 0
  fi
  if [[ -n "$nearest_uvtoml" ]]; then
    printf '%s\n' "$nearest_uvtoml"; return 0
  fi
  return 1
}
