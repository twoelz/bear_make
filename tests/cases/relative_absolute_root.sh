#!/usr/bin/env bash
# Test: Relative vs absolute root path

run_test() {
  print_test "Relative vs absolute root path"
  mkdir -p "$TEST_DIR/root_path_test/subdir"
  cat > "$TEST_DIR/root_path_test/Makefile" <<'EOF'
all:
	@echo "Building"
	@touch output.o

clean:
	@rm -f *.o
EOF
  cd "$TEST_DIR/root_path_test/subdir"
  # Test relative path
  if "$BEAR_MAKE" --root ../ --no-clean >/dev/null 2>&1 && [ -f "../compile_commands.json" ]; then
    pass "Relative root path works"
    rm -f "../compile_commands.json"
  else
    fail "Relative root path failed"
  fi
  # Test absolute path
  if "$BEAR_MAKE" --root "$TEST_DIR/root_path_test" --no-clean >/dev/null 2>&1 && [ -f "$TEST_DIR/root_path_test/compile_commands.json" ]; then
    pass "Absolute root path works"
  else
    fail "Absolute root path failed"
  fi
  cd "$TEST_DIR"
}
