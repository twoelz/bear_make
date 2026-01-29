#!/usr/bin/env bash
# Test: Symbolic links handling

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && exec "$(dirname "$0")/../test_bear_make.sh" "$(basename "${BASH_SOURCE[0]}" .sh)"

run_test() {
  print_test "Symbolic links handling"
  mkdir -p "$TEST_DIR/symlink_test/real_project"
  cat > "$TEST_DIR/symlink_test/real_project/Makefile" <<'EOF'
all:
	@echo "Building from real project"
	@touch output.o

clean:
	@rm -f *.o
EOF
  # Sub-test 1: Symlinked Makefile
  mkdir -p "$TEST_DIR/symlink_test/linked_makefile"
  ln -s "$TEST_DIR/symlink_test/real_project/Makefile" "$TEST_DIR/symlink_test/linked_makefile/Makefile"
  cd "$TEST_DIR/symlink_test/linked_makefile"
  if "$BEAR_MAKE" --no-clean >/dev/null 2>&1 && [ -f "compile_commands.json" ]; then
    pass "Symlinked Makefile works"
  else
    fail "Symlinked Makefile failed"
  fi
  # Sub-test 2: Symlinked .git directory
  mkdir -p "$TEST_DIR/symlink_test/real_git/.git"
  mkdir -p "$TEST_DIR/symlink_test/project_with_linked_git"
  ln -s "$TEST_DIR/symlink_test/real_git/.git" "$TEST_DIR/symlink_test/project_with_linked_git/.git"
  cat > "$TEST_DIR/symlink_test/project_with_linked_git/Makefile" <<'EOF'
all:
	@echo "Building"

clean:
	@echo "Cleaning"
EOF
  mkdir -p "$TEST_DIR/symlink_test/project_with_linked_git/subdir"
  cd "$TEST_DIR/symlink_test/project_with_linked_git/subdir"
  OUTPUT=$("$BEAR_MAKE" --no-clean 2>&1 || true)
  if echo "$OUTPUT" | grep -q "project_with_linked_git"; then
    pass "Symlinked .git directory detected"
  else
    fail "Symlinked .git directory not detected"
  fi
  # Sub-test 3: Access project via symlink
  mkdir -p "$TEST_DIR/symlink_test/another_project"
  cat > "$TEST_DIR/symlink_test/another_project/Makefile" <<'EOF'
all:
	@echo "Building"
	@touch output.o

clean:
	@rm -f *.o
EOF
  ln -s "$TEST_DIR/symlink_test/another_project" "$TEST_DIR/symlink_test/project_link"
  cd "$TEST_DIR/symlink_test/project_link"
  if "$BEAR_MAKE" --no-clean >/dev/null 2>&1 && [ -f "compile_commands.json" ]; then
    pass "Project accessed via symlink works"
  else
    fail "Project accessed via symlink failed"
  fi
  cd "$TEST_DIR"
}
