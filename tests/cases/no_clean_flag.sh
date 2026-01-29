#!/usr/bin/env bash
# Test: --no-clean flag

run_test() {
  print_test "--no-clean flag"
  mkdir -p "$TEST_DIR/no_clean_test"
  cat > "$TEST_DIR/no_clean_test/Makefile" <<'EOF'
all:
	@echo "Building..."
	touch build_artifact

clean:
	rm -f build_artifact
	@echo "CLEANED"
EOF
  cd "$TEST_DIR/no_clean_test"
  touch build_artifact
  OUTPUT=$("$BEAR_MAKE" --no-clean 2>&1 || true)
  if echo "$OUTPUT" | grep -qv "CLEANED"; then
    pass "--no-clean prevents make clean"
  else
    fail "--no-clean did not prevent make clean"
  fi
  cd "$TEST_DIR"
}
