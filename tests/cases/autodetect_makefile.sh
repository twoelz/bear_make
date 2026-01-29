#!/usr/bin/env bash
# Test: Auto-detect project root with Makefile

run_test() {
  print_test "Auto-detect root with Makefile"
  mkdir -p "$TEST_DIR/project/src"
  cat > "$TEST_DIR/project/Makefile" <<'EOF'
all:
	@echo "Building..."
	gcc -o test test.c

clean:
	rm -f test *.o
EOF
  cat > "$TEST_DIR/project/test.c" <<'EOF'
int main() { return 0; }
EOF
  cd "$TEST_DIR/project/src"
  if "$BEAR_MAKE" --no-clean 2>&1 | grep -q "project"; then
    pass "Auto-detected Makefile root"
  else
    fail "Failed to auto-detect Makefile root"
  fi
  cd "$TEST_DIR"
}
