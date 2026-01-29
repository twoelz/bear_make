#!/usr/bin/env bash
# Test: Custom output location

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && exec "$(dirname "$0")/../test_bear_make.sh" "$(basename "${BASH_SOURCE[0]}" .sh)"

run_test() {
  print_test "Custom output location"
  mkdir -p "$TEST_DIR/custom_out"
  cat > "$TEST_DIR/custom_out/Makefile" <<'EOF'
all:
	@echo "Building..."
	touch dummy.o

clean:
	rm -f *.o
EOF
  cd "$TEST_DIR/custom_out"
  if "$BEAR_MAKE" --output custom_compile.json --no-clean >/dev/null 2>&1 && [ -f "custom_compile.json" ]; then
    pass "Custom output location works"
  else
    fail "Custom output location failed"
  fi
  cd "$TEST_DIR"
}
