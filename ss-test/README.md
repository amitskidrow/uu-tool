<!-- >>> uu:init readme (ss-test) -->
### Make-only control for 'ss-test'

#### Quick Commands (Unsuffixed)
```sh
make up      # Start with live reload (default)
make down    # Stop and clean
make logs    # Recent logs
make follow  # Stream logs
make ps      # Status
make restart # Restart service
make unit    # Inspect systemd unit metadata
make journal # Show recent journal entries
```

#### Service-Specific Commands
```sh
make up.ss-test      # Start this specific service
make down.ss-test    # Stop this specific service
make logs.ss-test    # Logs for this service
make follow.ss-test  # Follow logs for this service
make ps.ss-test      # Status for this service
```

#### Live Reload (Development)
By default, services start with live reload using `pymon`:
```sh
make up             # Starts with live reload (RELOAD=1)
RELOAD=0 make up    # Disable live reload
```
Requires `pymon` (package: `py-mon`):
```sh
uv add py-mon
```
Ignored paths: `.uu/`, `__pycache__`, `.git`, `.venv`

If `pymon` is not installed and `RELOAD=1`, the start exits with a helpful message. Disable via `RELOAD=0` or install `py-mon`.

#### Configuration
> Default entry: python main.py (module: /home/ss/PycharmProjects/playground/ss-test, project: /home/ss/PycharmProjects/playground)
> Override example: `make up ENTRY="python worker.py --port 9000"`

#### Advanced Options
Hardened mode: set `SECURE=1` to enable stronger systemd sandboxing.
```sh
SECURE=1 make up
```

Doctor (no systemd):
```sh
make doctor
```

#### Multi-Service Usage
When multiple services exist, unsuffixed commands require selection:
```sh
SERVICE=worker make up
make up.worker
```
If more than one service is detected and no `SERVICE` is set, unsuffixed commands emit a helpful error listing available services.

#### Troubleshooting
- Live reload fails: `uv add py-mon`
- First run fails: ensure `.venv` exists before `SECURE=1`
- Check logs: `make logs` or `journalctl --user -u uu-ss-test -e`
- Conflicts: use service-specific targets `make up.ss-test`
<!-- <<< uu:init readme (ss-test) -->

