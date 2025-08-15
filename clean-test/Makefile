### >>> uu:init make (clean-test) (DO NOT EDIT)
# Make-only uu glue for service 'clean-test' (module-local)

# === Fixed, overridable variables ===
SERVICE := clean-test
MODULE  := $(abspath .)
PROJECT := /home/ss/PycharmProjects/playground/clean-test
ENTRY   ?= python main.py
# Stable-but-unique unit name derived from module path to avoid clashes with any persistent units
UNIT_SUFFIX := $(shell echo -n "$(abspath .)" | sha1sum | cut -c1-8)
UNIT    := uu-$(SERVICE)-$(UNIT_SUFFIX)
RUNDIR  := $(MODULE)/.uu/$(SERVICE)
RUNLOG  := $(RUNDIR)/run.log
TAIL   ?= 100
UU_ASCII ?= 0
SECURE ?= 0

.PHONY: up.clean-test down.clean-test logs.clean-test follow.clean-test ps.clean-test restart.clean-test doctor.clean-test unit.clean-test journal.clean-test

# Target-specific vars to avoid cross-service bleed
TARGETS_clean-test := up.clean-test down.clean-test logs.clean-test follow.clean-test ps.clean-test restart.clean-test doctor.clean-test unit.clean-test journal.clean-test
$(TARGETS_clean-test): SERVICE:=clean-test
$(TARGETS_clean-test): MODULE:=$(abspath .)
$(TARGETS_clean-test): PROJECT:=/home/ss/PycharmProjects/playground/clean-test
$(TARGETS_clean-test): ENTRY:=python main.py
$(TARGETS_clean-test): UNIT:=uu-clean-test-$(shell echo -n "$(abspath .)" | sha1sum | cut -c1-8)
$(TARGETS_clean-test): RUNDIR:=$(abspath .)/.uu/clean-test
$(TARGETS_clean-test): RUNLOG:=$(abspath .)/.uu/clean-test/run.log

# Start: create runtime dir, truncate log, then launch via systemd-run
up.clean-test:
	@mkdir -p "$(RUNDIR)" && : > "$(RUNLOG)"
	@echo "[UU] up svc=$(SERVICE) unit=$(UNIT) dir=$(MODULE) entry="$(ENTRY)""
	# Force unbuffered Python IO so logs immediately reach RUNLOG
	@if [ "$(SECURE)" = "1" ]; then 	  systemd-run --user 	    --unit="$(UNIT)" 	    --property=WorkingDirectory="$(MODULE)" 	    --property=NoNewPrivileges=yes 	    --property=PrivateTmp=yes 	    --property=ProtectSystem=strict 	    --property=ProtectHome=read-only 	    --property=RestrictSUIDSGID=yes 	    --property=RestrictAddressFamilies="AF_UNIX AF_INET AF_INET6" 	    --property=LockPersonality=yes 	    --property=MemoryDenyWriteExecute=yes 	    --property=TimeoutStartSec=30s 	    --property=Restart=no 	    --property=StandardOutput=append:"$(RUNLOG)" 	    --property=StandardError=append:"$(RUNLOG)" 	    --setenv=PYTHONUNBUFFERED=1 --setenv=PYTHONUTF8=1 	    bash -lc 'uv run --project "$(PROJECT)" -- $(ENTRY)'; 	else 	  systemd-run --user 	    --unit="$(UNIT)" 	    --property=WorkingDirectory="$(MODULE)" 	    --property=TimeoutStartSec=30s 	    --property=Restart=no 	    --property=StandardOutput=append:"$(RUNLOG)" 	    --property=StandardError=append:"$(RUNLOG)" 	    --setenv=PYTHONUNBUFFERED=1 --setenv=PYTHONUTF8=1 	    bash -lc 'uv run --project "$(PROJECT)" -- $(ENTRY)'; 	fi || { 	  echo "[UU] start failed. Try: make doctor.clean-test"; 	  echo "[UU] troubleshoot: journalctl --user -u $(UNIT) -e"; 	  echo "[UU] tip: enable hardening with SECURE=1 once .venv exists"; 	  exit 1; 	}

# Stop: stop the unit and clean ephemeral logs/state
down.clean-test:
	@echo "[UU] down svc=$(SERVICE) unit=$(UNIT) dir=$(MODULE)"
	@systemctl --user stop "$(UNIT)" >/dev/null 2>&1 || true
	@systemctl --user reset-failed "$(UNIT)" >/dev/null 2>&1 || true
	@rm -f "$(RUNLOG)" "$(RUNDIR)/meta.json" "$(RUNDIR)/.lock" 2>/dev/null || true

# Status: single-line summary for LLMs
ps.clean-test:
	@ACTIVE=$$(systemctl --user show -p ActiveState --value "$(UNIT)" 2>/dev/null || echo inactive); 	SUB=$$(systemctl --user show -p SubState --value "$(UNIT)" 2>/dev/null || echo -); 	PID=$$(systemctl --user show -p MainPID --value "$(UNIT)" 2>/dev/null || echo -); 	STATE=INACTIVE; 	if [ "$$ACTIVE" = "active" ] && [ "$$SUB" = "running" ]; then STATE=RUNNING; 	elif [ "$$ACTIVE" = "activating" ]; then STATE=STARTING; 	elif [ "$$ACTIVE" = "failed" ]; then STATE=FAILED; fi; 	echo "[UU] ps svc=$(SERVICE) state=$$STATE pid=$$PID uptime=-"

# Logs (snapshot): default non-blocking view
logs.clean-test:
	@echo "[UU] logs svc=$(SERVICE) tail=$(TAIL) dir=$(MODULE)"; 	if [ "$(UU_ASCII)" = "1" ]; then echo "------[ LOG ]-----"; else echo "──────────────[ LOG ]─────────────"; fi; 	if [ -s "$(RUNLOG)" ]; then 	  tail -n $(TAIL) "$(RUNLOG)" | sed 's/^/[LOG] /'; 	else 	  ACTIVE=$$(systemctl --user is-active "$(UNIT)" 2>/dev/null || true); 	  if [ "$$ACTIVE" = "active" ] || [ "$$ACTIVE" = "activating" ]; then 	    journalctl --user -u "$(UNIT)" -n $(TAIL) --no-pager | sed 's/^/[JRN] /'; exit 0; 	  else 	    echo "[UU] logs svc=$(SERVICE) no-log not-running dir=$(MODULE)"; exit 5; 	  fi; 	fi

# Logs (follow): stream raw lines after a single header and separator
follow.clean-test:
	@echo "[UU] logs svc=$(SERVICE) follow dir=$(MODULE)"; 	if [ "$(UU_ASCII)" = "1" ]; then echo "------[ LOG ]-----"; else echo "──────────────[ LOG ]─────────────"; fi; 	if [ -s "$(RUNLOG)" ]; then 	  tail -F "$(RUNLOG)"; 	else 	  journalctl --user -u "$(UNIT)" -f --no-pager; 	fi

# Restart: down then up
restart.clean-test:
	@$(MAKE) -s down.clean-test || true
	@$(MAKE) -s up.clean-test

# Doctor: run without systemd for quick diagnostics
doctor.clean-test:
	@echo "[UU] doctor svc=$(SERVICE) dir=$(MODULE) entry="$(ENTRY)""; 	uv run --project "$(PROJECT)" -- $(ENTRY)

# Inspect unit metadata and journal quickly
unit.clean-test:
	@systemctl --user show "$(UNIT)" -p Id,LoadState,ActiveState,SubState,FragmentPath --no-pager

journal.clean-test:
	@journalctl --user -u "$(UNIT)" -n $(TAIL) --no-pager
### <<< uu:init make (clean-test)
### >>> uu:init make (worker-svc) (DO NOT EDIT)
# Make-only uu glue for service 'worker-svc' (module-local)

# === Fixed, overridable variables ===
SERVICE := worker-svc
MODULE  := $(abspath .)
PROJECT := /home/ss/PycharmProjects/playground/clean-test
ENTRY   ?= python worker.py
# Stable-but-unique unit name derived from module path to avoid clashes with any persistent units
UNIT_SUFFIX := $(shell echo -n "$(abspath .)" | sha1sum | cut -c1-8)
UNIT    := uu-$(SERVICE)-$(UNIT_SUFFIX)
RUNDIR  := $(MODULE)/.uu/$(SERVICE)
RUNLOG  := $(RUNDIR)/run.log
TAIL   ?= 100
UU_ASCII ?= 0
SECURE ?= 0

.PHONY: up.worker-svc down.worker-svc logs.worker-svc follow.worker-svc ps.worker-svc restart.worker-svc doctor.worker-svc unit.worker-svc journal.worker-svc

# Target-specific vars to avoid cross-service bleed
TARGETS_worker-svc := up.worker-svc down.worker-svc logs.worker-svc follow.worker-svc ps.worker-svc restart.worker-svc doctor.worker-svc unit.worker-svc journal.worker-svc
$(TARGETS_worker-svc): SERVICE:=worker-svc
$(TARGETS_worker-svc): MODULE:=$(abspath .)
$(TARGETS_worker-svc): PROJECT:=/home/ss/PycharmProjects/playground/clean-test
$(TARGETS_worker-svc): ENTRY:=python worker.py
$(TARGETS_worker-svc): UNIT:=uu-worker-svc-$(shell echo -n "$(abspath .)" | sha1sum | cut -c1-8)
$(TARGETS_worker-svc): RUNDIR:=$(abspath .)/.uu/worker-svc
$(TARGETS_worker-svc): RUNLOG:=$(abspath .)/.uu/worker-svc/run.log

# Start: create runtime dir, truncate log, then launch via systemd-run
up.worker-svc:
	@mkdir -p "$(RUNDIR)" && : > "$(RUNLOG)"
	@echo "[UU] up svc=$(SERVICE) unit=$(UNIT) dir=$(MODULE) entry=\"$(ENTRY)\""
	# Force unbuffered Python IO so logs immediately reach RUNLOG
	@if [ "$(SECURE)" = "1" ]; then 	  systemd-run --user 	    --unit="$(UNIT)" 	    --property=WorkingDirectory="$(MODULE)" 	    --property=NoNewPrivileges=yes 	    --property=PrivateTmp=yes 	    --property=ProtectSystem=strict 	    --property=ProtectHome=read-only 	    --property=RestrictSUIDSGID=yes 	    --property=RestrictAddressFamilies="AF_UNIX AF_INET AF_INET6" 	    --property=LockPersonality=yes 	    --property=MemoryDenyWriteExecute=yes 	    --property=TimeoutStartSec=30s 	    --property=Restart=no 	    --property=StandardOutput=append:"$(RUNLOG)" 	    --property=StandardError=append:"$(RUNLOG)" 	    --setenv=PYTHONUNBUFFERED=1 --setenv=PYTHONUTF8=1 	    bash -lc 'uv run --project "$(PROJECT)" -- $(ENTRY)'; 	else 	  systemd-run --user 	    --unit="$(UNIT)" 	    --property=WorkingDirectory="$(MODULE)" 	    --property=TimeoutStartSec=30s 	    --property=Restart=no 	    --property=StandardOutput=append:"$(RUNLOG)" 	    --property=StandardError=append:"$(RUNLOG)" 	    --setenv=PYTHONUNBUFFERED=1 --setenv=PYTHONUTF8=1 	    bash -lc 'uv run --project "$(PROJECT)" -- $(ENTRY)'; 	fi || { 	  echo "[UU] start failed. Try: make doctor.worker-svc"; 	  echo "[UU] troubleshoot: journalctl --user -u $(UNIT) -e"; 	  echo "[UU] tip: enable hardening with SECURE=1 once .venv exists"; 	  exit 1; 	}

# Stop: stop the unit and clean ephemeral logs/state
down.worker-svc:
	@echo "[UU] down svc=$(SERVICE) unit=$(UNIT) dir=$(MODULE)"
	@systemctl --user stop "$(UNIT)" >/dev/null 2>&1 || true
	@systemctl --user reset-failed "$(UNIT)" >/dev/null 2>&1 || true
	@rm -f "$(RUNLOG)" "$(RUNDIR)/meta.json" "$(RUNDIR)/.lock" 2>/dev/null || true

# Status: single-line summary for LLMs
ps.worker-svc:
	@ACTIVE=$$(systemctl --user show -p ActiveState --value "$(UNIT)" 2>/dev/null || echo inactive); 	SUB=$$(systemctl --user show -p SubState --value "$(UNIT)" 2>/dev/null || echo -); 	PID=$$(systemctl --user show -p MainPID --value "$(UNIT)" 2>/dev/null || echo -); 	STATE=INACTIVE; 	if [ "$$ACTIVE" = "active" ] && [ "$$SUB" = "running" ]; then STATE=RUNNING; 	elif [ "$$ACTIVE" = "activating" ]; then STATE=STARTING; 	elif [ "$$ACTIVE" = "failed" ]; then STATE=FAILED; fi; 	echo "[UU] ps svc=$(SERVICE) state=$$STATE pid=$$PID uptime=-"

# Logs (snapshot): default non-blocking view
logs.worker-svc:
	@echo "[UU] logs svc=$(SERVICE) tail=$(TAIL) dir=$(MODULE)"; 	if [ "$(UU_ASCII)" = "1" ]; then echo "------[ LOG ]-----"; else echo "──────────────[ LOG ]─────────────"; fi; 	if [ -s "$(RUNLOG)" ]; then 	  tail -n $(TAIL) "$(RUNLOG)" | sed 's/^/[LOG] /'; 	else 	  ACTIVE=$$(systemctl --user is-active "$(UNIT)" 2>/dev/null || true); 	  if [ "$$ACTIVE" = "active" ] || [ "$$ACTIVE" = "activating" ]; then 	    journalctl --user -u "$(UNIT)" -n $(TAIL) --no-pager | sed 's/^/[JRN] /'; exit 0; 	  else 	    echo "[UU] logs svc=$(SERVICE) no-log not-running dir=$(MODULE)"; exit 5; 	  fi; 	fi

# Logs (follow): stream raw lines after a single header and separator
follow.worker-svc:
	@echo "[UU] logs svc=$(SERVICE) follow dir=$(MODULE)"; 	if [ "$(UU_ASCII)" = "1" ]; then echo "------[ LOG ]-----"; else echo "──────────────[ LOG ]─────────────"; fi; 	if [ -s "$(RUNLOG)" ]; then 	  tail -F "$(RUNLOG)"; 	else 	  journalctl --user -u "$(UNIT)" -f --no-pager; 	fi

# Restart: down then up
restart.worker-svc:
	@$(MAKE) -s down.worker-svc || true
	@$(MAKE) -s up.worker-svc

# Doctor: run without systemd for quick diagnostics
doctor.worker-svc:
	@echo "[UU] doctor svc=$(SERVICE) dir=$(MODULE) entry=\"$(ENTRY)\""; 	uv run --project "$(PROJECT)" -- $(ENTRY)

# Inspect unit metadata and journal quickly
unit.worker-svc:
	@systemctl --user show "$(UNIT)" -p Id,LoadState,ActiveState,SubState,FragmentPath --no-pager

journal.worker-svc:
	@journalctl --user -u "$(UNIT)" -n $(TAIL) --no-pager
### <<< uu:init make (worker-svc)
