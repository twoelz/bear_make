#!/usr/bin/env bash
# Test: Auto-detect project root with .git

run_test() {
  print_test "Auto-detect root with .git"
  mkdir -p "$TEST_DIR/gitproject/subdir"
  mkdir -p "$TEST_DIR/gitproject/.git"
  cat > "$TEST_DIR/gitproject/Makefile" <<'EOF'
all:
	@echo "Building..."

clean:
	@echo "Cleaning..."
EOF
  cd "$TEST_DIR/gitproject/subdir"
  if "$BEAR_MAKE" --no-clean 2>&1 | grep -q "gitproject"; then
    pass "Auto-detected .git root"
  else
    fail "Failed to auto-detect .git root"
  fi
  cd "$TEST_DIR"
}
