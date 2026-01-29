#!/usr/bin/env bash
# Test: Relative output path conversion

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && exec "$(dirname "$0")/../test_bear_make.sh" "$(basename "${BASH_SOURCE[0]}" .sh)"

run_test() {
  print_test "Relative output path conversion"
  mkdir -p "$TEST_DIR/relative_output_test/build"
  cat > "$TEST_DIR/relative_output_test/Makefile" <<'EOF'
all:
	@echo "Building"
	@touch output.o

clean:
	@rm -f *.o
EOF
  cd "$TEST_DIR/relative_output_test"
  if "$BEAR_MAKE" --output build/compile_commands.json --no-clean >/dev/null 2>&1 && [ -f "$TEST_DIR/relative_output_test/build/compile_commands.json" ]; then
    pass "Relative output path converted to absolute"
  else
    fail "Relative output path conversion failed"
  fi
  cd "$TEST_DIR"
}
