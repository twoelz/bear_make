#!/usr/bin/env bash
# Test: Help flag (-h)

run_test() {
  print_test "Help flag (-h)"
  if "$BEAR_MAKE" -h >/dev/null 2>&1; then
    pass "Help flag works"
  else
    fail "Help flag failed"
  fi
}
