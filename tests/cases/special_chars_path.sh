#!/usr/bin/env bash
# Test: Special characters in paths

run_test() {
  print_test "Special characters in directory names"
  mkdir -p "$TEST_DIR/my project (test)"
  cat > "$TEST_DIR/my project (test)/Makefile" <<'EOF'
all:
	@echo "Building with spaces"
	@touch output.o

clean:
	@rm -f *.o
EOF
  cd "$TEST_DIR/my project (test)"
  if "$BEAR_MAKE" --no-clean >/dev/null 2>&1 && [ -f "compile_commands.json" ]; then
    pass "Handles special characters in paths"
  else
    fail "Failed with special characters in paths"
  fi
  cd "$TEST_DIR"
}
