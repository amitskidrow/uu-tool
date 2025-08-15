#!/usr/bin/env bash

# File-system related helpers for block upsert and .gitignore updates

# Replace or append a tagged block inside a file.
# Args: file start_marker end_marker new_content
upsert_block() {
  local file="$1"; shift
  local start="$1"; shift
  local end="$1"; shift
  local content="$1"
  local tmp; tmp=$(mktemp)

  if [[ -f "$file" ]] && grep -qF "$start" "$file"; then
    awk -v start="$start" -v end="$end" -v repl="$content" '
      BEGIN{ replaced=0 }
      {
        if (!replaced && index($0,start)) { print repl; inblk=1; replaced=1; next }
        if (inblk && index($0,end)) { inblk=0; next }
        if (!inblk) print $0
      }
      END{ if(!replaced) print repl }' "$file" >"$tmp"
  else
    { [[ -f "$file" ]] && cat "$file"; printf "%s\n" "$content"; } >"$tmp"
  fi

  if (( DRY_RUN )); then
    info "DRY-RUN: would write to $file this block:\n---"
    sed -n "/$(printf '%s' "$start" | sed 's/[^^]/[&]/g; s/\^/\\^/g')/,/$(printf '%s' "$end" | sed 's/[^^]/[&]/g; s/\^/\\^/g')/p" "$tmp" || true
    info "--- end block"
    rm -f "$tmp"
  else
    mv "$tmp" "$file"
    ok "Wrote $file"
  fi
}

append_gitignore() {
  local file="$1"; local line="$2"
  if [[ -f "$file" ]] && grep -qxF "$line" "$file"; then ok ".gitignore already contains: $line"; return; fi
  if (( DRY_RUN )); then info "DRY-RUN: would append to $file: $line"; else echo "$line" >> "$file"; ok "Appended to $file: $line"; fi
}

