#!/usr/bin/env bash
# Test: --output conflict detection

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && exec "$(dirname "$0")/../test_bear_make.sh" "$(basename "${BASH_SOURCE[0]}" .sh)"

run_test() {
  print_test "Conflict detection for --output"
  mkdir -p "$TEST_DIR/conflict_test"
  cat > "$TEST_DIR/conflict_test/Makefile" <<'EOF'
all:
	@echo "test"
clean:
	@echo "clean"
EOF
  cd "$TEST_DIR/conflict_test"
  OUTPUT=$("$BEAR_MAKE" --output myfile.json --flags "--output other.json" 2>&1 || true)
  if echo "$OUTPUT" | grep -q "Error.*Cannot use --output"; then
    pass "Correctly detects --output conflict"
  else
    fail "Failed to detect --output conflict"
  fi
  cd "$TEST_DIR"
}
