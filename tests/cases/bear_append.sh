#!/usr/bin/env bash
# Test: Bear's --append flag

run_test() {
  print_test "Bear --append flag"
  mkdir -p "$TEST_DIR/append_test"
  cat > "$TEST_DIR/append_test/Makefile" <<'EOF'
CC=gcc

file1.o: file1.c
	$(CC) -c file1.c -o file1.o

file2.o: file2.c
	$(CC) -c file2.c -o file2.o

clean:
	rm -f *.o
EOF
  cat > "$TEST_DIR/append_test/file1.c" <<'EOF'
int func1() { return 1; }
EOF
  cat > "$TEST_DIR/append_test/file2.c" <<'EOF'
int func2() { return 2; }
EOF
  cd "$TEST_DIR/append_test"
  # First run: build file1.o
  "$BEAR_MAKE" -- file1.o >/dev/null 2>&1
  FIRST_SIZE=$(wc -l < compile_commands.json 2>/dev/null || echo "0")
  # Second run: append file2.o
  "$BEAR_MAKE" --flags "--append" -- file2.o >/dev/null 2>&1
  SECOND_SIZE=$(wc -l < compile_commands.json 2>/dev/null || echo "0")
  if [ "$SECOND_SIZE" -gt "$FIRST_SIZE" ] && grep -q "file1.c" "compile_commands.json" && grep -q "file2.c" "compile_commands.json"; then
    pass "Bear --append flag works"
  else
    fail "Bear --append flag failed"
  fi
  cd "$TEST_DIR"
}
