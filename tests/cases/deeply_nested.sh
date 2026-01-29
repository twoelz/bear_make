#!/usr/bin/env bash
# Test: Deeply nested subdirectory

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && exec "$(dirname "$0")/../test_bear_make.sh" "$(basename "${BASH_SOURCE[0]}" .sh)"

run_test() {
  print_test "Deeply nested subdirectory"
  mkdir -p "$TEST_DIR/deep/project/src/components/ui"
  cat > "$TEST_DIR/deep/project/Makefile" <<'EOF'
all:
	@echo "Building from deep project"

clean:
	@echo "Cleaning"
EOF
  cd "$TEST_DIR/deep/project/src/components/ui"
  OUTPUT=$("$BEAR_MAKE" --no-clean 2>&1 || true)
  if echo "$OUTPUT" | grep -q "deep/project"; then
    pass "Found root from nested directory"
  else
    fail "Failed to find root from nested directory"
  fi
  cd "$TEST_DIR"
}
