#!/usr/bin/env bash
# Test: --clangd writes .clangd beside compile_commands.json; does not overwrite

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && exec "$(dirname "$0")/../test_bear_make.sh" "$(basename "${BASH_SOURCE[0]}" .sh)"

run_test() {
  print_test "--clangd creates .clangd and skips if present"
  mkdir -p "$TEST_DIR/clangd_test"
  cat > "$TEST_DIR/clangd_test/Makefile" <<'EOF'
all:
	@echo "Building..."
	touch dummy.o

clean:
	rm -f *.o
EOF
  cd "$TEST_DIR/clangd_test"

  if ! "$BEAR_MAKE" --clangd --no-clean >/dev/null 2>&1; then
    fail "bear_make --clangd failed"
    cd "$TEST_DIR"
    return
  fi

  if [[ ! -f .clangd ]]; then
    fail ".clangd was not created"
    cd "$TEST_DIR"
    return
  fi

  expected=$'CompileFlags:\n  CompilationDatabase: .'
  if [[ "$(cat .clangd)" != "$expected" ]]; then
    fail ".clangd content mismatch"
    cd "$TEST_DIR"
    return
  fi

  echo "custom: true" >> .clangd
  if ! "$BEAR_MAKE" --clangd --no-clean >/dev/null 2>&1; then
    fail "bear_make --clangd (second run) failed"
    cd "$TEST_DIR"
    return
  fi

  if ! grep -q '^custom: true$' .clangd; then
    fail "existing .clangd was overwritten"
    cd "$TEST_DIR"
    return
  fi

  pass "--clangd creates and preserves existing .clangd"
  cd "$TEST_DIR"
}
