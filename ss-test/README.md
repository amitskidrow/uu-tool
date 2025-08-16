<!-- >>> uu:init readme (ss-test) -->
### Make-only control for 'ss-test'

#### Quick Commands (Unsuffixed)

For single-service modules, use these short commands:

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

For multi-service setups or explicit control:

```sh
make up.ss-test      # Start this specific service
make down.ss-test    # Stop this specific service
make logs.ss-test    # Logs for this service
make follow.ss-test  # Follow logs for this service
make ps.ss-test      # Status for this service
```

#### Live Reload (Development)

By default, services start with **live reload** using `pymon`:

```sh
make up                    # Starts with live reload (RELOAD=1)
RELOAD=0 make up          # Disable live reload
```

Live reload watches for file changes and automatically restarts your service. Requires `pymon`:

```sh
uv add py-mon             # Add live-reload tool
```

Ignored paths: `.uu/`, `__pycache__`, `.git`, `.venv`

+If `pymon` is not installed and `RELOAD=1`, the start command exits gracefully with a helpful message. Disable reload via `RELOAD=0` or install `py-mon`.

#### Configuration

> Default entry: **python main.py** (module: /home/ss/PycharmProjects/playground/ss-test, project: /home/ss/PycharmProjects/playground/ss-test)
> Override example: `make up ENTRY="python worker.py --port 9000"`

#### Advanced Options

Hardened mode (opt-in): set `SECURE=1` to enable stronger systemd sandboxing.

```sh
SECURE=1 make up
```

Doctor (no systemd): run the command in-foreground for quick verification.

```sh
make doctor
```

#### Multi-Service Usage

When multiple services exist in the same Makefile, unsuffixed commands require explicit service selection:

```sh
SERVICE=worker make up    # Start specific service
make up.worker           # Alternative syntax
```

+If more than one service is detected and no `SERVICE` is set, unsuffixed commands emit a helpful error listing available services.

#### Troubleshooting

- **Live reload fails**: Ensure `pymon` is installed: `uv add py-mon`
- **First run fails**: Ensure `uv` can create `.venv` (avoid `ProtectHome=read-only` unless venv exists)
- **Check logs**: `make logs` or journal: `journalctl --user -u uu-ss-test -e`
- **Service conflicts**: Use service-specific targets: `make up.ss-test`
<!-- <<< uu:init readme (ss-test) -->
