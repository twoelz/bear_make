#!/usr/bin/env bash
# Test: Help flag (-h)

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && exec "$(dirname "$0")/../test_bear_make.sh" "$(basename "${BASH_SOURCE[0]}" .sh)"

run_test() {
  print_test "Help flag (-h)"
  if "$BEAR_MAKE" -h >/dev/null 2>&1; then
    pass "Help flag works"
  else
    fail "Help flag failed"
  fi
}
