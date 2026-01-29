#!/usr/bin/env bash
# Test: Empty --flags argument

run_test() {
  print_test "Empty --flags argument"
  mkdir -p "$TEST_DIR/empty_flags"
  cat > "$TEST_DIR/empty_flags/Makefile" <<'EOF'
all:
	@echo "Building"
	@touch output.o

clean:
	@rm -f *.o
EOF
  cd "$TEST_DIR/empty_flags"
  if "$BEAR_MAKE" --flags "" --no-clean >/dev/null 2>&1 && [ -f "compile_commands.json" ]; then
    pass "Empty --flags argument works"
  else
    fail "Empty --flags argument failed"
  fi
  cd "$TEST_DIR"
}
