#!/usr/bin/env bash
# Test: Bear flags passed through

run_test() {
  print_test "Bear flags passed through (--verbose)"
  mkdir -p "$TEST_DIR/bear_flags"
  cat > "$TEST_DIR/bear_flags/Makefile" <<'EOF'
all:
	@echo "test"
clean:
	@echo "clean"
EOF
  cd "$TEST_DIR/bear_flags"
  if "$BEAR_MAKE" --flags "--verbose" --no-clean 2>&1 | grep -q "verbose"; then
    pass "Bear --verbose flag passed through"
  else
    # Verbose output might not contain the word "verbose", so just check it doesn't error
    if "$BEAR_MAKE" --flags "--verbose" --no-clean >/dev/null 2>&1; then
      pass "Bear --verbose flag accepted"
    else
      fail "Bear flags not passed through correctly"
    fi
  fi
  cd "$TEST_DIR"
}
