#!/usr/bin/env bash
# uupm-init.sh — bootstrap a uv-based Python module directory for Make-only control
#
# Purpose: In the TARGET MODULE DIRECTORY (folder that contains runnable .py like main.py),
# generate:
#   • Makefile glue (dot-notation targets that call systemd-run/systemctl/tail directly)
#   • README snippet documenting the Make-only workflow
#   • .gitignore entry for `.uu/`
#
# Design:
#   • Default entry is `python main.py` (overridable via --entry or Make: ENTRY='python worker.py ...')
#   • Runtime dir is `.uu/<service>/`; logs at `.uu/<service>/run.log` (ephemeral)
#   • Output contract: one compact [UU] header line; pretty separator; then [LOG] lines (snapshot) or raw stream (follow)
#   • No external CLI: users/LLMs run `make up.<svc>`, `make logs.<svc>`, `make follow.<svc>`, `make down.<svc>`, `make ps.<svc>`
#
# Exit codes:
#  0 OK | 2 bad args | 3 missing tools | 4 path/pyproject issues | 5 write failure
set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_NAME=${0##*/}
VERSION="0.3.0"

# Defaults
SERVICE=""
ENTRY=""           # If empty -> computed default
MAKEFILE_OUT="Makefile"
README_OUT="README.md"
DRY_RUN=0
YES=0
MK_ONLY=0
README_ONLY=0

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

parse_args() {
  (( $# >= 1 )) || { usage; exit 2; }
  TARGET_INPUT="$1"; shift || true
  while (( $# )); do
    case "$1" in
      --service) SERVICE="$2"; shift 2 ;;
      --entry) ENTRY="$2"; shift 2 ;;
      --makefile-out) MAKEFILE_OUT="$2"; shift 2 ;;
      --readme-out) README_OUT="$2"; shift 2 ;;
      --mk-only) MK_ONLY=1; shift ;;
      --readme-only) README_ONLY=1; shift ;;
      --dry-run) DRY_RUN=1; shift ;;
      --yes) YES=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
    esac
  done
  if (( MK_ONLY && README_ONLY )); then warn "--mk-only and --readme-only both set; will generate both."; fi
}

find_project_root() {
  local d="$1"
  while [[ "$d" != "/" ]]; do
    if [[ -f "$d/pyproject.toml" ]]; then echo "$d"; return 0; fi
    d="${d%/*}"
  done
  return 1
}

confirm() {
  (( YES )) && return 0
  read -r -p "$* [y/N] " ans || true
  case "$ans" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

main() {
  parse_args "$@"

  need_tool uv
  need_tool systemd-run
  need_tool awk
  need_tool sed
  need_tool grep

  # Normalize target
  local MODULE_ABS ENTRY_DEFAULT
  local INPUT_ABS; INPUT_ABS=$(abs_dir "$TARGET_INPUT")
  if [[ -d "$INPUT_ABS" ]]; then
    MODULE_ABS="$INPUT_ABS"
    ENTRY_DEFAULT="python main.py"
  elif [[ -f "$INPUT_ABS" && "$INPUT_ABS" == *.py ]]; then
    MODULE_ABS="$(dirname -- "$INPUT_ABS")"
    ENTRY_DEFAULT="python $(basename -- "$INPUT_ABS")"
  else
    echo "[ERR] Target is neither a directory nor a .py file: $TARGET_INPUT" >&2; exit 4
  fi

  # Find uv project root (must exist)
  local PROJECT_ROOT
  PROJECT_ROOT=$(find_project_root "$MODULE_ABS") || { echo "[ERR] pyproject.toml not found above: $MODULE_ABS" >&2; exit 4; }

  # Compute service name if not provided
  if [[ -z "$SERVICE" ]]; then
    local base; base=$(basename -- "$MODULE_ABS")
    SERVICE=$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9._-]//g')
  fi

  # Compute entry if not provided
  if [[ -z "$ENTRY" ]]; then
    ENTRY="$ENTRY_DEFAULT"
  fi

  # Preflights
  if [[ ! -d "$MODULE_ABS" ]]; then echo "[ERR] Module dir not found: $MODULE_ABS" >&2; exit 4; fi
  if [[ ! -w "$MODULE_ABS" ]]; then echo "[ERR] Module dir not writable: $MODULE_ABS" >&2; exit 4; fi
  if [[ "$ENTRY_DEFAULT" == "python main.py" && ! -f "$MODULE_ABS/main.py" ]]; then
    warn "main.py not found in module dir; default ENTRY will likely fail. Consider --entry."
  fi

  info "Module dir   : $MODULE_ABS"
  info "Project root : $PROJECT_ROOT"
  info "Service name : $SERVICE"
  info "Entrypoint   : $ENTRY"
  info "Makefile out : $MAKEFILE_OUT"
  info "README out   : $README_OUT"

  if ! confirm "Proceed with these settings?"; then warn "Aborted by user"; exit 0; fi

  cd "$MODULE_ABS"

  # --- Prepare templated blocks ---
  local mk_start mk_end rd_start rd_end
  mk_start="### >>> uu:init make ($SERVICE) (DO NOT EDIT)"
  mk_end="### <<< uu:init make ($SERVICE)"
  rd_start="<!-- >>> uu:init readme ($SERVICE) -->"
  rd_end="<!-- <<< uu:init readme ($SERVICE) -->"

  # NOTE: escape $ as \$ and $$ as \$\$ so Make sees variables; expand ${PROJECT_ROOT} and ${SERVICE} now.
  local mk_block rd_block
  read -r -d '' mk_block <<EOF || true
${mk_start}
# Make-only uu glue for service '${SERVICE}' (module-local)

# === Fixed, overridable variables ===
SERVICE := ${SERVICE}
MODULE  := \$(abspath .)
PROJECT := ${PROJECT_ROOT}
ENTRY   ?= ${ENTRY}
UNIT    := uu-\$(SERVICE)
RUNDIR  := \$(MODULE)/.uu/\$(SERVICE)
RUNLOG  := \$(RUNDIR)/run.log
TAIL   ?= 100
UU_ASCII ?= 0
SECURE ?= 0

.PHONY: up.${SERVICE} down.${SERVICE} logs.${SERVICE} follow.${SERVICE} ps.${SERVICE} restart.${SERVICE} doctor.${SERVICE}

# Target-specific vars to avoid cross-service bleed
TARGETS_${SERVICE} := up.${SERVICE} down.${SERVICE} logs.${SERVICE} follow.${SERVICE} ps.${SERVICE} restart.${SERVICE} doctor.${SERVICE}
\$(TARGETS_${SERVICE}): SERVICE:=${SERVICE}
\$(TARGETS_${SERVICE}): MODULE:=\$(abspath .)
\$(TARGETS_${SERVICE}): PROJECT:=${PROJECT_ROOT}
\$(TARGETS_${SERVICE}): ENTRY:=${ENTRY}
\$(TARGETS_${SERVICE}): UNIT:=uu-${SERVICE}
\$(TARGETS_${SERVICE}): RUNDIR:=\$(abspath .)/.uu/${SERVICE}
\$(TARGETS_${SERVICE}): RUNLOG:=\$(abspath .)/.uu/${SERVICE}/run.log

# Start: create runtime dir, truncate log, then launch via systemd-run
up.${SERVICE}:
	@mkdir -p "\$(RUNDIR)" && : > "\$(RUNLOG)"
	@echo "[UU] up svc=\$(SERVICE) unit=\$(UNIT) dir=\$(MODULE) entry=\"\$(ENTRY)\""
	@if [ "\$(SECURE)" = "1" ]; then \
	  systemd-run --user \
	    --unit="\$(UNIT)" \
	    --property=WorkingDirectory="\$(MODULE)" \
	    --property=NoNewPrivileges=yes \
	    --property=PrivateTmp=yes \
	    --property=ProtectSystem=strict \
	    --property=ProtectHome=read-only \
	    --property=RestrictSUIDSGID=yes \
	    --property=RestrictAddressFamilies="AF_UNIX AF_INET AF_INET6" \
	    --property=LockPersonality=yes \
	    --property=MemoryDenyWriteExecute=yes \
	    --property=TimeoutStartSec=30s \
	    --property=Restart=no \
	    --property=StandardOutput=append:"\$(RUNLOG)" \
	    --property=StandardError=append:"\$(RUNLOG)" \
	    bash -lc 'uv run --project "\$(PROJECT)" -- \$(ENTRY)'; \
	else \
	  systemd-run --user \
	    --unit="\$(UNIT)" \
	    --property=WorkingDirectory="\$(MODULE)" \
	    --property=TimeoutStartSec=30s \
	    --property=Restart=no \
	    --property=StandardOutput=append:"\$(RUNLOG)" \
	    --property=StandardError=append:"\$(RUNLOG)" \
	    bash -lc 'uv run --project "\$(PROJECT)" -- \$(ENTRY)'; \
	fi || { \
	  echo "[UU] start failed. Try: make doctor.${SERVICE}"; \
	  echo "[UU] troubleshoot: journalctl --user -u \$(UNIT) -e"; \
	  echo "[UU] tip: enable hardening with SECURE=1 once .venv exists"; \
	  exit 1; \
	}

# Stop: stop the unit and clean ephemeral logs/state
down.${SERVICE}:
	@echo "[UU] down svc=\$(SERVICE) unit=\$(UNIT) dir=\$(MODULE)"
	@systemctl --user stop "\$(UNIT)" >/dev/null 2>&1 || true
	@rm -f "\$(RUNLOG)" "\$(RUNDIR)/meta.json" "\$(RUNDIR)/.lock" 2>/dev/null || true

# Status: single-line summary for LLMs
ps.${SERVICE}:
	@ACTIVE=\$\$(systemctl --user show -p ActiveState --value "\$(UNIT)" 2>/dev/null || echo inactive); \
	SUB=\$\$(systemctl --user show -p SubState --value "\$(UNIT)" 2>/dev/null || echo -); \
	PID=\$\$(systemctl --user show -p MainPID --value "\$(UNIT)" 2>/dev/null || echo -); \
	STATE=INACTIVE; \
	if [ "\$\$ACTIVE" = "active" ] && [ "\$\$SUB" = "running" ]; then STATE=RUNNING; \
	elif [ "\$\$ACTIVE" = "activating" ]; then STATE=STARTING; \
	elif [ "\$\$ACTIVE" = "failed" ]; then STATE=FAILED; fi; \
	echo "[UU] ps svc=\$(SERVICE) state=\$\$STATE pid=\$\$PID uptime=-"

# Logs (snapshot): default non-blocking view
logs.${SERVICE}:
	@echo "[UU] logs svc=\$(SERVICE) tail=\$(TAIL) dir=\$(MODULE)"; \
	if [ "\$(UU_ASCII)" = "1" ]; then echo "------[ LOG ]-----"; else echo "──────────────[ LOG ]─────────────"; fi; \
	if [ -f "\$(RUNLOG)" ]; then \
	  tail -n \$(TAIL) "\$(RUNLOG)" | sed 's/^/[LOG] /'; \
	else \
	  ACTIVE=\$\$(systemctl --user is-active "\$(UNIT)" 2>/dev/null || true); \
	  if [ "\$\$ACTIVE" = "active" ] || [ "\$\$ACTIVE" = "activating" ]; then \
	    echo "[UU] logs svc=\$(SERVICE) no-output-yet dir=\$(MODULE)"; exit 0; \
	  else \
	    echo "[UU] logs svc=\$(SERVICE) no-log not-running dir=\$(MODULE)"; exit 5; \
	  fi; \
	fi

# Logs (follow): stream raw lines after a single header and separator
follow.${SERVICE}:
	@echo "[UU] logs svc=\$(SERVICE) follow dir=\$(MODULE)"; \
	if [ "\$(UU_ASCII)" = "1" ]; then echo "------[ LOG ]-----"; else echo "──────────────[ LOG ]─────────────"; fi; \
	tail -F "\$(RUNLOG)"

# Restart: down then up
restart.${SERVICE}:
	@\$(MAKE) -s down.${SERVICE} || true
	@\$(MAKE) -s up.${SERVICE}

# Doctor: run without systemd for quick diagnostics
doctor.${SERVICE}:
	@echo "[UU] doctor svc=\$(SERVICE) dir=\$(MODULE) entry=\"\$(ENTRY)\""; \
	uv run --project "\$(PROJECT)" -- \$(ENTRY)
${mk_end}
EOF

  read -r -d '' rd_block <<'EOF' || true
${rd_start}
### Make-only control for '${SERVICE}'

Start the service (transient `systemd-run --user` + `uv run --project`):

```sh
make up.${SERVICE}
```

Check recent logs without blocking (default window 100 lines):

```sh
make logs.${SERVICE}
```

Follow logs (blocks until Ctrl-C):

```sh
make follow.${SERVICE}
```

Stop and clean ephemeral logs/state:

```sh
make down.${SERVICE}
```

Status in one line (LLM-friendly):

```sh
make ps.${SERVICE}
```

> Default entry: **${ENTRY}** (module: ${MODULE_ABS}, project: ${PROJECT_ROOT})
> Override example: `make up.${SERVICE} ENTRY="python worker.py --port 9000"`

Hardened mode (opt-in): set `SECURE=1` to enable stronger systemd sandboxing.

```sh
SECURE=1 make up.${SERVICE}
```

Doctor (no systemd): run the command in-foreground for quick verification.

```sh
make doctor.${SERVICE}
```

Troubleshooting:
- If the first run fails, ensure `uv` can create `.venv` (avoid `ProtectHome=read-only` unless venv exists).
- Check logs: `make logs.${SERVICE}` or journal: `journalctl --user -u uu-${SERVICE} -e`.
${rd_end}
EOF

  # --- Write files in module dir ---
  if (( ! README_ONLY )); then upsert_block "$MAKEFILE_OUT" "$mk_start" "$mk_end" "$mk_block"; fi
  if (( ! MK_ONLY )); then upsert_block "$README_OUT" "$rd_start" "$rd_end" "$rd_block"; fi

  # Ensure .gitignore has .uu/
  if [[ -f .gitignore ]]; then
    append_gitignore .gitignore ".uu/"
  else
    if (( DRY_RUN )); then info "DRY-RUN: would create .gitignore with '.uu/'"; else echo ".uu/" > .gitignore; ok "Created .gitignore with .uu/"; fi
  fi

  ok "Initialization complete. Next: cd '$MODULE_ABS' and run: make up.${SERVICE}"
}

main "$@"
