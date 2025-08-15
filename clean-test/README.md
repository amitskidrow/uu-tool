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
