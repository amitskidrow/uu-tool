# Abstract Insights: Bash Script Modularization Challenges

## Context
Refactoring a monolithic bash script (`uupm-init.sh` → `uu`) into modular components while maintaining zero-regression behavior. The script generates Makefile and README templates with complex variable expansion.

## Critical Issues Encountered & Solutions

### 1. **Template Variable Scoping in Heredocs**
**Problem**: When extracting template generation into separate functions, variables like `${SERVICE}`, `${PROJECT_ROOT}`, `${ENTRY}` were undefined in the function scope, causing bash to execute commands during template generation.

**Root Cause**: Bash heredoc expansion (`<<EOF`) happens in the current scope. Variables defined in `main()` as local variables are not accessible in sourced functions.

**Failed Solutions**:
- Passing variables as function parameters (complex, error-prone)
- Using global variables (scope issues persisted)

**Working Solution**: Keep templates inline in the main function where variables are defined, exactly like the original script.

**Key Insight**: For complex template generation with many variable references, inline heredocs are more reliable than extracted functions.

### 2. **Command Execution During Heredoc Processing**
**Problem**: The error `error: a value is required for '--project <PROJECT>'` indicated that `uv run` commands were being executed during template generation, not just stored as text.

**Root Cause**: Improper escaping of quotes in bash command strings within heredocs. Single quotes in `bash -lc 'uv run...'` were being processed by bash during expansion.

**Failed Solutions**:
- Escaping with `'\''` (created more complexity)
- Using different quoting strategies

**Working Solution**: Keep the exact same heredoc structure as the original, with proper escaping already in place.

**Key Insight**: When refactoring working bash code with complex quoting, preserve the exact structure rather than trying to "improve" it.

### 3. **Argument Parsing Edge Cases**
**Problem**: `./uu --help` failed because the argument parser required a target input before processing help flags.

**Root Cause**: The original logic checked for minimum arguments before processing flags.

**Solution**: Pre-process help flags before validating argument count.

**Key Insight**: Help should always be accessible regardless of other argument requirements.

### 4. **Library Path Resolution**
**Problem**: Sourced modules need to be found reliably from different execution contexts.

**Solution**: Robust path resolution with fallback candidates:
```bash
UU_LIB_DIR_CANDIDATES=(
  "${UU_LIB_DIR:-}"           # Environment override
  "${SCRIPT_DIR}/lib/uu"      # Repo layout
  "${SCRIPT_DIR}/../lib/uu"   # Installed layout
)
```

**Key Insight**: Always provide multiple path resolution strategies for different deployment scenarios.

## Modularization Strategy Lessons

### What Worked Well:
1. **Clean functional separation**: Each module has a focused responsibility
2. **Preserved global variables**: Maintained original variable scope and naming
3. **Robust sourcing**: Library resolution works in multiple contexts
4. **Zero-regression testing**: Comparing outputs byte-by-byte caught subtle issues

### What Didn't Work:
1. **Over-modularization of templates**: Complex heredocs with many variables are better kept inline
2. **Parameter passing for templates**: Too many variables made function signatures unwieldy
3. **"Improving" working code**: The original quoting and escaping was correct; changes introduced bugs

## General Principles

### 1. **Preserve Working Patterns**
When refactoring working bash code, especially with complex quoting, variable expansion, or heredocs, preserve the exact patterns that work rather than trying to "clean them up."

### 2. **Test Early and Often**
Use timeout commands and byte-by-byte output comparison to catch issues immediately:
```bash
timeout 10 ./script --test
diff <(original_script) <(new_script)
```

### 3. **Modularize by Concern, Not by Size**
- ✅ Separate argument parsing, file operations, project detection
- ❌ Extract complex templates with many variable dependencies

### 4. **Variable Scope Awareness**
In bash, local variables in functions are not accessible to sourced scripts. Plan variable scope carefully when modularizing.

### 5. **Incremental Refactoring**
- Start with no-op refactors (grouping functions)
- Extract pure functions first (no side effects)
- Keep complex interdependent code together

## Debugging Techniques Used

1. **Timeout commands**: Prevent hanging during development
2. **Debug output**: Strategic `echo` statements to trace execution
3. **Output comparison**: Diff original vs refactored output
4. **Isolated testing**: Test individual components in isolation
5. **Progressive rollback**: When stuck, revert to last working state

## File Structure Outcome

```
uu                    # Main executable (templates inline)
lib/uu/
├── common.sh        # Pure utility functions
├── fs.sh           # File operations
├── project.sh      # Project detection
└── args.sh         # Argument parsing
```

**Key Decision**: Templates stayed in main script due to variable scope complexity.

## Time Investment
- Initial modularization: ~30 minutes
- Debugging template issues: ~45 minutes  
- Final working solution: ~15 minutes

**Lesson**: Sometimes the "obvious" refactoring (extract templates) is not the right approach. Understanding the original code's constraints is crucial.