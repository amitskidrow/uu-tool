Got it — no backward-compat commands. Here's a tight plan updated for the current modular `uu` system.

**Plan**
- Add unsuffixed targets: `up`, `down`, `logs`, `follow`, `restart`, `ps`, `doctor`, `journal`, `unit`.
- Integrate pymon reload: wrap ENTRY with `pymon` so it auto-restarts on file changes.
- Toggle behavior: `RELOAD=1` default; if pymon missing, fail fast with clear error.
- Ignore loops: exclude `.uu/`, `__pycache__`, `.git`, `.venv` from watch to avoid self-triggered reloads.
- Service auto-detection: single service auto-delegates, multiple services require SERVICE variable.
- README update: new commands, `RELOAD` usage, notes on installing `pymon` as a dev dep.
- Smoke test: up → edit a `.py` → observe restart → logs/follow → down.

**Opinion**
- Live reload viability: Excellent. Running `pymon` inside a transient `systemd-run --user` unit works from first principles:
  - The systemd unit hosts a single long-lived process (pymon); pymon manages child restarts internally on FS change.
  - The unit's state remains RUNNING across restarts (only the child restarts), so `ps` stays meaningful.
  - Logs: Append to a stable `run.log`. `follow` uses `tail -F` so reloads don't break streaming.
  - Watch mechanism: inotify-based watchers only need read access; systemd hardening is opt-in and won't block basic file reads.

- Unsuffixed workflow: Perfect for single-service modules and reduces mental overhead and typing. Multi-service scenarios use explicit SERVICE variable.

- Pymon integration: Clean and simple. Add `pymon` to `[tool.uv].dev-dependencies` so `uv run` can resolve it offline from the local lock once installed.

- Edge cases to expect:
  - Double-reload conflicts: If your ENTRY already has its own reloader (e.g., `uvicorn --reload`, `watchfiles`), you'll get redundant restarts. Prefer only one reloader.
  - Watch scope: Exclude `.uu/`, `__pycache__`, `.venv`, `.git` to cut noise.
  - Non-Python changes: Pymon by default may watch all files; scope appropriately.

**Implementation approach**
- `RELOAD=1` by default; disable with `RELOAD=0 make up`.
- Unsuffixed commands delegate to service-specific targets via auto-detection.
- Require `pymon` presence - fail fast with clear error message if missing.
- Generate both suffixed (existing) and unsuffixed (new) targets in the same Makefile template.

**Current system context**
- Working with modular `uu` script (replaces legacy `uupm-init.sh`)
- Template generation happens in main() function with inline heredocs
- Preserve existing working patterns per `abstract_insights.md` lessons
- All changes happen in the Makefile template within the `uu` script

Ready to implement: unsuffixed targets, `pymon` integration with `RELOAD` toggle and fail-fast behavior, ignore rules, and updated README snippet.