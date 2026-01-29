#!/usr/bin/env bash
# Test: Output specified via --flags only (without script --output)

run_test() {
  print_test "Output specified via --flags only"
  mkdir -p "$TEST_DIR/flags_output"
  cat > "$TEST_DIR/flags_output/Makefile" <<'EOF'
all:
	@echo "Building"
	@touch dummy.o

clean:
	@rm -f *.o
EOF
  cd "$TEST_DIR/flags_output"
  OUTPUT=$("$BEAR_MAKE" --flags "--output custom_via_flags.json" --no-clean 2>&1 || true)
  if [ -f "custom_via_flags.json" ]; then
    pass "Output via --flags works"
  else
    fail "Output via --flags failed"
  fi
  cd "$TEST_DIR"
}
