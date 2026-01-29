#!/usr/bin/env bash
# Test: Custom make arguments

run_test() {
  print_test "Custom make arguments"
  mkdir -p "$TEST_DIR/make_args"
  cat > "$TEST_DIR/make_args/Makefile" <<'EOF'
all:
	@echo "all target"

custom:
	@echo "CUSTOM_TARGET"

clean:
	@echo "clean"
EOF
  cd "$TEST_DIR/make_args"
  OUTPUT=$("$BEAR_MAKE" --no-clean -- custom 2>&1 || true)
  if echo "$OUTPUT" | grep -q "CUSTOM_TARGET"; then
    pass "Custom make arguments work"
  else
    fail "Custom make arguments failed"
  fi
  cd "$TEST_DIR"
}
