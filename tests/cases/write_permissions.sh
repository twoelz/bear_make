#!/usr/bin/env bash
# Test: Write permission validation

run_test() {
  print_test "Write permission validation"
  mkdir -p "$TEST_DIR/perm_test"
  cat > "$TEST_DIR/perm_test/Makefile" <<'EOF'
all:
	@echo "Building"

clean:
	@echo "Cleaning"
EOF
  cd "$TEST_DIR/perm_test"
  # Sub-test 1: Non-existent directory
  OUTPUT=$("$BEAR_MAKE" --output /tmp/nonexistent_bear_dir_xyz/compile_commands.json --no-clean 2>&1 || true)
  if echo "$OUTPUT" | grep -q "Output directory does not exist"; then
    pass "Detects non-existent output directory"
  else
    fail "Failed to detect non-existent output directory"
  fi
  # Sub-test 2: Permission denied (only test if /root is not writable)
  if [[ ! -w /root ]]; then
    OUTPUT=$("$BEAR_MAKE" --output /root/compile_commands.json --no-clean 2>&1 || true)
    if echo "$OUTPUT" | grep -q "No write permission"; then
      pass "Detects write permission issues"
    else
      fail "Failed to detect write permission issues"
    fi
  else
    pass "Write permission check skipped (running as root)"
  fi
  cd "$TEST_DIR"
}
