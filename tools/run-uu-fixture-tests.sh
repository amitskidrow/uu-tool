#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")"/.. && pwd -P)"

green() { printf "\033[32m%s\033[0m\n" "$*"; }
red()   { printf "\033[31m%s\033[0m\n" "$*"; }

run() {
  echo "+ $*"; "$@"
}

echo "[1/4] Validate existing Makefile with validator (clean-test/Makefile)"
if [[ -f "$root_dir/clean-test/Makefile" ]]; then
  if run "$root_dir/tools/uu-validate-makefile.sh" "$root_dir/clean-test/Makefile"; then
    green "validator: clean-test/Makefile OK"
  else
    red   "validator: clean-test/Makefile FAILED"
  fi
else
  echo "(skipped: clean-test/Makefile not found)"
fi

echo
echo "[2/4] Single-service fixture: unsuffixed targets auto-select service"
pushd "$root_dir/test-workspace/uu-fixtures/single" >/dev/null
run make -s up
run make -s ps
popd >/dev/null

echo
echo "[3/4] Multi-service fixture: unsuffixed requires SERVICE; shows helpful error"
set +e
pushd "$root_dir/test-workspace/uu-fixtures/multi" >/dev/null
make -s up
rc=$?
popd >/dev/null
set -e
if [[ $rc -ne 0 ]]; then
  green "as-expected: 'make up' exited non-zero due to missing SERVICE"
else
  red   "unexpected: 'make up' succeeded without SERVICE in multi-service fixture"
fi

echo
echo "[4/4] Multi-service fixture: works with explicit SERVICE"
pushd "$root_dir/test-workspace/uu-fixtures/multi" >/dev/null
run make -s SERVICE=app up
run make -s SERVICE=worker up
popd >/dev/null

green "All fixture tests executed. Review output above for behavior."

