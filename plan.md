Got it — no backward-compat commands. Here’s a tight plan and an honest take.

**Plan**
- Add unsuffixed targets: `up`, `down`, `logs`, `follow`, `restart`, `ps`, `doct
or`, `journal`, `unit`.
- Integrate pymon reload: wrap ENTRY with `pymon` so it auto-restarts on file ch
anges.
- Toggle and fallback: `RELOAD=1` default; if pymon missing, warn and run withou
t reload.
- Ignore loops: exclude `.uu/` from watch to avoid self-triggered reloads.
- README update: new commands, `RELOAD` usage, notes on installing `pymon` as a 
dev dep.
- Smoke test: up → edit a `.py` → observe restart → logs/follow → down.

**Opinion**
- Live reload viability: Good. Running `pymon` inside a transient `systemd-run -
-user` unit works from first principles:
  - The systemd unit hosts a single long-lived process (pymon); pymon manages ch
ild restarts internally on FS change.
  - The unit’s state remains RUNNING across restarts (only the child restarts), 
so `ps` stays meaningful.
  - Logs: Append to a stable `run.log`. `follow` uses `tail -F` so reloads don’t
 break streaming.
  - Watch mechanism: inotify-based watchers only need read access; systemd harde
ning is opt-in and won’t block basic file reads. Avoid enabling `ProtectHome=rea
d-only` until the venv exists (as your current notes already say).
e workflow. It reduces mental overhead and typing. The only caveat is future mul
ti-service expansion would need a different pattern (another `Makefile` per modu
le or a top-level orchestration), which is fine.
- Pymon choice: Pragmatically okay if it’s available in your env or listed as a 
dev dependency. For robustness:
  - Add `pymon` to `[tool.uv].dev-dependencies` (or your dev group) so `uv run` 
can resolve it offline from the local lock once installed.
  - Fallback path keeps `make up` working even if `pymon` isn’t present.
- Edge cases to expect:
  - Double-reload conflicts: If your ENTRY already has its own reloader (e.g., `
uvicorn --reload`, `watchfiles`), you’ll get redundant restarts. Prefer only one
 reloader.
  - Watch scope: Exclude `.uu/` and optionally `__pycache__`, `.venv`, `.git` to
 cut noise.
  - Non-Python changes: Pymon by default may watch all files; if edits to non-Py

**Recommended defaults**
- `RELOAD=1` by default; disable with `RELOAD=0 make up`.
- Unsuffixed commands only; keep `SERVICE` as an internal var to name the unit a
nd `.uu` path.
- Detect `pymon` presence and print a clear `[UU] reload requested but 'pymon' n
ot found; running without reload` message when missing.

If you’re aligned, I’ll implement: unsuffixed targets, `pymon` integration with 
`RELOAD` toggle and safe fallback, ignore rules, and updated README snippet.