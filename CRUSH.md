CRUSH.md - Code Review, Unblock, Solve, Help, and Ship Guidelines

- Build, lint, and test commands (including single-test execution):
  - Run full suite: npm run test  // or python -m pytest, etc. adapt to project
  - Run lint: npm run lint  // or flake8/ruff depending on repo
  - Run a single test: pytest tests/test_xyz.py -k "test_name"  # adjust as needed
  - CI-lite: python -m pytest -q; npm ci; npm run lint

- Project code style guidelines:
  - Imports: group stdlib, third-party, then local; alphabetize within groups; no unused imports
  - Formatting: 2 spaces or 4 spaces per repo convention; ensure trailing newline
  - Types: use explicit types where possible; prefer typing over Any; handle Optional safely
  - Naming: clear, descriptive names; consistent camelCase or snake_case per language; avoid abbreviations
  - Errors: propagate meaningful errors; avoid bare except; log context; return early on validation
  - Documentation: docstrings for functions/classes; README for module overview; comments sparingly
  - Testing: test edge cases; add tests for new features; use fixtures; deterministic tests

- Cursor and Copilot rules (if present):
  - Follow repository-specific cursor rules if found under .cursor/rules/ or .cursor.json
  - Respect Copilot guidance in .github/copilot-instructions.md if present

- .gitignore and artifacts:
  - Ensure .crush/ is ignored: add a .crush directory to ignore list
  - Do not commit temporary or local environment files

- Quick setup reminders:
  - Ensure virtualenv/venv setup commands are documented
  - Document how to run tests in a clean environment
