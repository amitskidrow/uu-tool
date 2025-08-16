### >>> uu:init make (ss-test) (DO NOT EDIT)
# Make-only uu glue for service 'ss-test' (module-local)

# === Fixed, overridable variables ===
SERVICE := ss-test
MODULE  := $(abspath .)
PROJECT := /home/ss/PycharmProjects/playground/ss-test
ENTRY   ?= python main.py
RELOAD  ?= 1
# Stable-but-unique unit name derived from module path to avoid clashes with any persistent units
UNIT_SUFFIX := $(shell echo -n "$(abspath .)" | sha1sum | cut -c1-8)
UNIT    := uu-$(SERVICE)-$(UNIT_SUFFIX)
RUNDIR  := $(MODULE)/.uu/$(SERVICE)
RUNLOG  := $(RUNDIR)/run.log
TAIL   ?= 100
UU_ASCII ?= 0
SECURE ?= 0

# Aggregate the list of services present in this Makefile (one entry per block)
UU_SERVICES += ss-test

.PHONY: up.ss-test down.ss-test logs.ss-test follow.ss-test ps.ss-test restart.ss-test doctor.ss-test unit.ss-test journal.ss-test

# Target-specific vars to avoid cross-service bleed
TARGETS_ss-test := up.ss-test down.ss-test logs.ss-test follow.ss-test ps.ss-test restart.ss-test doctor.ss-test unit.ss-test journal.ss-test
$(TARGETS_ss-test): SERVICE:=ss-test
$(TARGETS_ss-test): MODULE:=$(abspath .)
$(TARGETS_ss-test): PROJECT:=/home/ss/PycharmProjects/playground/ss-test
$(TARGETS_ss-test): ENTRY:=python main.py
$(TARGETS_ss-test): UNIT:=uu-ss-test-$(shell echo -n "$(abspath .)" | sha1sum | cut -c1-8)
$(TARGETS_ss-test): RUNDIR:=$(abspath .)/.uu/ss-test
$(TARGETS_ss-test): RUNLOG:=$(abspath .)/.uu/ss-test/run.log

# Unsuffixed targets: define only once, with runtime service selection
ifndef UU_UNSUFFIXED_DEFINED
UU_UNSUFFIXED_DEFINED := 1

.PHONY: up down logs follow ps restart doctor unit journal check-service

# Choose default service if only one exists; otherwise require SERVICE=<name>
# Only honor SERVICE when passed on the command line, not from later blocks
DEFAULT_SERVICE = $(if $(filter 1,$(words $(UU_SERVICES))),$(firstword $(UU_SERVICES)),)
CLI_SERVICE = $(if $(filter command line,$(origin SERVICE)),$(SERVICE),)
TARGET_SERVICE = $(if $(CLI_SERVICE),$(CLI_SERVICE),$(DEFAULT_SERVICE))

check-service:
	@if [ -z "$(TARGET_SERVICE)" ]; then 	  echo "[UU] Multiple services detected: $(UU_SERVICES)"; 	  echo "[UU] Please specify SERVICE=<name>, e.g.: SERVICE=$(firstword $(UU_SERVICES)) make up"; 	  exit 2; 	fi

up: check-service
	@$(MAKE) -s up.$(TARGET_SERVICE)
down: check-service
	@$(MAKE) -s down.$(TARGET_SERVICE)
logs: check-service
	@$(MAKE) -s logs.$(TARGET_SERVICE)
follow: check-service
	@$(MAKE) -s follow.$(TARGET_SERVICE)
ps: check-service
	@$(MAKE) -s ps.$(TARGET_SERVICE)
restart: check-service
	@$(MAKE) -s restart.$(TARGET_SERVICE)
doctor: check-service
	@$(MAKE) -s doctor.$(TARGET_SERVICE)
unit: check-service
	@$(MAKE) -s unit.$(TARGET_SERVICE)
journal: check-service
	@$(MAKE) -s journal.$(TARGET_SERVICE)
endif

# Start: create runtime dir, truncate log, then launch via systemd-run
up.ss-test:
	@mkdir -p "$(RUNDIR)" && : > "$(RUNLOG)"
	@echo "[UU] up svc=$(SERVICE) unit=$(UNIT) dir=$(MODULE) entry="$(ENTRY)" reload=$(RELOAD)"
	# Force unbuffered Python IO so logs immediately reach RUNLOG
	@if [ "$(SECURE)" = "1" ]; then \
	  systemd-run --user \
	    --unit="$(UNIT)" \
	    --property=WorkingDirectory="$(MODULE)" \
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
	    --property=StandardOutput=append:"$(RUNLOG)" \
	    --property=StandardError=append:"$(RUNLOG)" \
	    --setenv=PYTHONUNBUFFERED=1 --setenv=PYTHONUTF8=1 \
	    bash -lc 'if [ "$(RELOAD)" = "1" ]; then \
	                if uv run --project "$(PROJECT)" -- python -c "import pymon" >/dev/null 2>&1; then \
	                  PYMON_FILE=$$(echo "$(ENTRY)" | sed "s/^python //"); \
	                  cd "$(MODULE)" && tail -f /dev/null | script -qfc "uv run --project "$(PROJECT)" -- pymon -i .uu/ -i __pycache__ -i .git -i .venv $$PYMON_FILE" /dev/null; \
	                else \
	                  echo "[UU] pymon not found; RELOAD=1 requires pymon. Disable via RELOAD=0 or install it (uv add py-mon)"; \
	                  exit 2; \
	                fi; \
	              else \
	                cd "$(MODULE)" && uv run --project "$(PROJECT)" -- $(ENTRY); \
	              fi'; \
	else \
	  systemd-run --user \
	    --unit="$(UNIT)" \
	    --property=WorkingDirectory="$(MODULE)" \
	    --property=TimeoutStartSec=30s \
	    --property=Restart=no \
	    --property=StandardOutput=append:"$(RUNLOG)" \
	    --property=StandardError=append:"$(RUNLOG)" \
	    --setenv=PYTHONUNBUFFERED=1 --setenv=PYTHONUTF8=1 \
	    bash -lc 'if [ "$(RELOAD)" = "1" ]; then \
	                if uv run --project "$(PROJECT)" -- python -c "import pymon" >/dev/null 2>&1; then \
	                  PYMON_FILE=$$(echo "$(ENTRY)" | sed "s/^python //"); \
	                  cd "$(MODULE)" && tail -f /dev/null | script -qfc "uv run --project "$(PROJECT)" -- pymon -i .uu/ -i __pycache__ -i .git -i .venv $$PYMON_FILE" /dev/null; \
	                else \
	                  echo "[UU] pymon not found; RELOAD=1 requires pymon. Disable via RELOAD=0 or install it (uv add py-mon)"; \
	                  exit 2; \
	                fi; \
	              else \
	                cd "$(MODULE)" && uv run --project "$(PROJECT)" -- $(ENTRY); \
	              fi'; \
	fi || { \
	  echo "[UU] start failed. Try: make doctor.ss-test"; \
	  echo "[UU] troubleshoot: journalctl --user -u $(UNIT) -e"; \
	  echo "[UU] tip: enable hardening with SECURE=1 once .venv exists"; \
	  exit 1; \
	}

# Stop: stop the unit and clean ephemeral logs/state
down.ss-test:
	@echo "[UU] down svc=$(SERVICE) unit=$(UNIT) dir=$(MODULE)"
	@systemctl --user stop "$(UNIT)" >/dev/null 2>&1 || true
	@systemctl --user reset-failed "$(UNIT)" >/dev/null 2>&1 || true
	@rm -f "$(RUNLOG)" "$(RUNDIR)/meta.json" "$(RUNDIR)/.lock" 2>/dev/null || true

# Status: single-line summary for LLMs
ps.ss-test:
	@ACTIVE=$$(systemctl --user show -p ActiveState --value "$(UNIT)" 2>/dev/null || echo inactive); 	SUB=$$(systemctl --user show -p SubState --value "$(UNIT)" 2>/dev/null || echo -); 	PID=$$(systemctl --user show -p MainPID --value "$(UNIT)" 2>/dev/null || echo -); 	STATE=INACTIVE; 	if [ "$$ACTIVE" = "active" ] && [ "$$SUB" = "running" ]; then STATE=RUNNING; 	elif [ "$$ACTIVE" = "activating" ]; then STATE=STARTING; 	elif [ "$$ACTIVE" = "failed" ]; then STATE=FAILED; fi; 	echo "[UU] ps svc=$(SERVICE) state=$$STATE pid=$$PID uptime=-"

# Logs (snapshot): default non-blocking view
logs.ss-test:
	@echo "[UU] logs svc=$(SERVICE) tail=$(TAIL) dir=$(MODULE)"; 	if [ "$(UU_ASCII)" = "1" ]; then echo "------[ LOG ]-----"; else echo "──────────────[ LOG ]─────────────"; fi; 	if [ -s "$(RUNLOG)" ]; then 	  tail -n $(TAIL) "$(RUNLOG)" | sed 's/^/[LOG] /'; 	else 	  ACTIVE=$$(systemctl --user is-active "$(UNIT)" 2>/dev/null || true); 	  if [ "$$ACTIVE" = "active" ] || [ "$$ACTIVE" = "activating" ]; then 	    journalctl --user -u "$(UNIT)" -n $(TAIL) --no-pager | sed 's/^/[JRN] /'; exit 0; 	  else 	    echo "[UU] logs svc=$(SERVICE) no-log not-running dir=$(MODULE)"; exit 5; 	  fi; 	fi

# Logs (follow): stream raw lines after a single header and separator
follow.ss-test:
	@echo "[UU] logs svc=$(SERVICE) follow dir=$(MODULE)"; 	if [ "$(UU_ASCII)" = "1" ]; then echo "------[ LOG ]-----"; else echo "──────────────[ LOG ]─────────────"; fi; 	if [ -s "$(RUNLOG)" ]; then 	  tail -F "$(RUNLOG)"; 	else 	  journalctl --user -u "$(UNIT)" -f --no-pager; 	fi

# Restart: down then up
restart.ss-test:
	@$(MAKE) -s down.ss-test || true
	@$(MAKE) -s up.ss-test

# Doctor: run without systemd for quick diagnostics
doctor.ss-test:
	@echo "[UU] doctor svc=$(SERVICE) dir=$(MODULE) entry="$(ENTRY)""; 	uv run --project "$(PROJECT)" -- $(ENTRY)

# Inspect unit metadata and journal quickly
unit.ss-test:
	@systemctl --user show "$(UNIT)" -p Id,LoadState,ActiveState,SubState,FragmentPath --no-pager

journal.ss-test:
	@journalctl --user -u "$(UNIT)" -n $(TAIL) --no-pager
### <<< uu:init make (ss-test)
