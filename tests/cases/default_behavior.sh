#!/usr/bin/env bash
# Test: Default behavior with no arguments

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && exec "$(dirname "$0")/../test_bear_make.sh" "$(basename "${BASH_SOURCE[0]}" .sh)"

run_test() {
  print_test "Default behavior (no arguments)"
  mkdir -p "$TEST_DIR/default_test"
  cat > "$TEST_DIR/default_test/Makefile" <<'EOF'
all:
	@echo "Building default"
	@touch output.o

clean:
	@rm -f *.o
EOF
  cd "$TEST_DIR/default_test"
  if "$BEAR_MAKE" >/dev/null 2>&1 && [ -f "compile_commands.json" ]; then
    pass "Default behavior works"
  else
    fail "Default behavior failed"
  fi
  cd "$TEST_DIR"
}
