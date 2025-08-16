# py-mon Package Integration: Fixes and Insights

## Overview

This document captures all the fixes, insights, and important notes regarding the integration of the `py-mon` package in the `uu` project. The main issue was inconsistent naming and references throughout the codebase that needed to be corrected.

## Package Details (Confirmed via Web Search)

### Correct Package Information
- **PyPI Package Name**: `py-mon`
- **Installation Command**: `uv add py-mon` (NOT `uv add pymon` or `uv add --dev pymon`)
- **CLI Command**: `pymon` (execute with `pymon filename.py`)
- **Import Name**: `pymon` (import with `import pymon`)
- **GitHub Repository**: https://github.com/kevinjosethomas/py-mon
- **Description**: Automatically restart application when file changes are detected; made for development

### Key Naming Convention
The package follows a common Python pattern:
- **Package name on PyPI**: Uses hyphens (`py-mon`)
- **Import name in Python**: Uses underscores or no separator (`pymon`)
- **CLI command**: Matches import name (`pymon`)

## Issues Found and Fixed

### 1. Main `uu` Script Template Issues

#### ✅ Fixed: Installation Instructions
**Before:**
```markdown
install `pymon`.
```

**After:**
```markdown
install `py-mon`.
```

**Location:** Line 352 in `uu` script

#### ✅ Already Correct: Detection Logic
The main `uu` script already had the correct modern detection logic:
```bash
uv run --project "$(PROJECT)" -- python -c "import pymon" >/dev/null 2>&1
```

### 2. Test Fixture Issues

#### ✅ Fixed: README Installation Commands
**Before:**
```bash
uv add --dev pymon        # Add as dev dependency
```

**After:**
```bash
uv add py-mon             # Add live-reload tool
```

**Locations:**
- `clean-test/README.md`
- `ss-test-venv/README.md`

#### ✅ Fixed: Error Message References
**Before:**
```bash
echo "[UU] pymon not found; RELOAD=1 requires pymon. Disable via RELOAD=0 or install it (uv add --dev pymon)";
```

**After:**
```bash
echo "[UU] pymon not found; RELOAD=1 requires pymon. Disable via RELOAD=0 or install it (uv add py-mon)";
```

#### ✅ Fixed: Makefile Detection Logic
**Before (Legacy):**
```bash
if command -v pymon >/dev/null 2>&1; then
```

**After (Modern uv-aware):**
```bash
if uv run --project "$(PROJECT)" -- python -c "import pymon" >/dev/null 2>&1; then
```

**Locations:**
- `clean-test/Makefile`
- `ss-test-venv/Makefile`

### 3. Troubleshooting Documentation

#### ✅ Fixed: Troubleshooting Instructions
**Before:**
```markdown
- **Live reload fails**: Ensure `pymon` is installed: `uv add --dev pymon`
```

**After:**
```markdown
- **Live reload fails**: Ensure `pymon` is installed: `uv add py-mon`
```

## Technical Implementation Details

### Modern Detection Strategy
The project uses a modern uv-aware detection strategy instead of relying on PATH:

```bash
# Modern approach (✅ Correct)
uv run --project "$(PROJECT)" -- python -c "import pymon" >/dev/null 2>&1

# Legacy approach (❌ Deprecated)
command -v pymon >/dev/null 2>&1
```

**Benefits of modern approach:**
- Works with virtual environments managed by uv
- Respects project-specific dependencies
- More reliable than PATH-based detection
- Consistent with uv's philosophy

### Package Installation Strategy
The project recommends installing `py-mon` as a regular dependency rather than a dev dependency:

```bash
# Recommended (✅)
uv add py-mon             # Add live-reload tool

# Previous approach (❌)
uv add --dev pymon        # Add as dev dependency
```

**Rationale:**
- Live reload is useful in both development and testing environments
- Simplifies dependency management
- Aligns with the tool's purpose as a development utility

## Validation and Testing

### Validation Tools Used
1. **Makefile Validation**: `./tools/uu-validate-makefile.sh`
2. **Fixture Testing**: `./tools/run-uu-fixture-tests.sh`
3. **Pattern Searching**: `grep -r` for consistency checks

### Test Results
All validation tests pass after fixes:
- ✅ Makefile validation for both test fixtures
- ✅ Single-service fixture tests
- ✅ Multi-service fixture tests
- ✅ No remaining legacy references

### Verification Commands
```bash
# Check for any remaining old references
grep -r "uv add --dev pymon" . --exclude-dir=.git
grep -r "command -v pymon" . --exclude-dir=.git

# Verify correct new references
grep -r "uv add py-mon" . --exclude-dir=.git
```

## Files Modified

### Direct Modifications
1. `uu` (main script) - Fixed installation instruction text
2. `clean-test/README.md` - Updated installation commands and troubleshooting
3. `ss-test-venv/README.md` - Updated installation commands and troubleshooting

### Regenerated Files
1. `clean-test/Makefile` - Regenerated with updated detection logic
2. `ss-test-venv/Makefile` - Regenerated with updated detection logic

### Already Correct
1. `uu-pymon-test/pyproject.toml` - Already used correct `py-mon`
2. `uu-pymon-test/README.md` - Already used correct installation commands

## Best Practices Established

### 1. Package Naming Consistency
- Always use `py-mon` when referring to the PyPI package
- Use `pymon` when referring to the CLI command or import name
- Be explicit about the context (installation vs. usage)

### 2. Detection Strategy
- Prefer `uv run import` over `command -v` for Python packages
- Include project context with `--project "$(PROJECT)"`
- Handle errors gracefully with proper redirects

### 3. Documentation Clarity
- Distinguish between package name and command name
- Provide clear installation instructions
- Include troubleshooting for common issues

## Common Pitfalls to Avoid

### 1. Package Name Confusion
❌ **Wrong**: `uv add pymon`
✅ **Correct**: `uv add py-mon`

### 2. Detection Method
❌ **Wrong**: `command -v pymon`
✅ **Correct**: `uv run --project "$(PROJECT)" -- python -c "import pymon"`

### 3. Dependency Type
❌ **Outdated**: `uv add --dev py-mon`
✅ **Current**: `uv add py-mon`

## Future Maintenance Notes

### When Adding New Test Fixtures
1. Ensure they use `uv add py-mon` for installation
2. Use modern `uv run import` detection
3. Include proper error messages with correct package name

### When Updating Documentation
1. Always refer to `py-mon` for installation
2. Use `pymon` when discussing the CLI command
3. Maintain consistency across all README files

### When Debugging Issues
1. Check that `py-mon` is installed (not `pymon`)
2. Verify import works: `python -c "import pymon"`
3. Test CLI availability: `pymon --help`

## Summary Statistics

After all fixes:
- ✅ 15 correct instances of `uv add py-mon` found
- ✅ 0 remaining `uv add --dev pymon` references
- ✅ 0 remaining `command -v pymon` references
- ✅ All validation tests passing
- ✅ All fixture tests passing

## Related Resources

- [py-mon GitHub Repository](https://github.com/kevinjosethomas/py-mon)
- [py-mon on PyPI](https://pypi.org/project/py-mon/)
- [uv Documentation](https://docs.astral.sh/uv/)

---

*This document was created to ensure consistent understanding and prevent regression of the py-mon package integration fixes.*