#!/usr/bin/env bash
# Test: No Makefile or .git found (fallback to current directory)

run_test() {
  print_test "Fallback when no Makefile or .git found"
  mkdir -p "$TEST_DIR/isolated_dir"
  cat > "$TEST_DIR/isolated_dir/Makefile" <<'EOF'
all:
	@echo "test"
clean:
	@echo "clean"
EOF
  cd "$TEST_DIR/isolated_dir"
  OUTPUT=$("$BEAR_MAKE" --no-clean 2>&1 || true)
  # Should use current directory (isolated_dir) as root since there's no parent Makefile or .git
  if echo "$OUTPUT" | grep -q "isolated_dir"; then
    pass "Falls back to current directory"
  else
    fail "Fallback to current directory failed"
  fi
  cd "$TEST_DIR"
}
