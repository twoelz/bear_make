#!/usr/bin/env bash
# Test: Output to different directory

run_test() {
  print_test "Output to different directory"
  mkdir -p "$TEST_DIR/diff_output"
  mkdir -p "$TEST_DIR/output_location"
  cat > "$TEST_DIR/diff_output/Makefile" <<'EOF'
all:
	@echo "Building"
	@touch output.o

clean:
	@rm -f *.o
EOF
  cd "$TEST_DIR/diff_output"
  if "$BEAR_MAKE" --output "$TEST_DIR/output_location/compile_commands.json" --no-clean >/dev/null 2>&1 && [ -f "$TEST_DIR/output_location/compile_commands.json" ]; then
    pass "Output to different directory works"
  else
    fail "Output to different directory failed"
  fi
  cd "$TEST_DIR"
}
