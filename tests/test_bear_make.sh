#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
NC=$'\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BEAR_MAKE="$SCRIPT_DIR/../bear_make"
TEST_DIR="/tmp/bear_make_test_$$"
PASSED=0
FAILED=0
TEST_NUMBER=0
SPECIFIC_TEST=""

show_help() {
  cat <<EOF
${BLUE}Bear Make Test Suite${NC}

Usage: $0 [OPTIONS] [TEST_NAME]

Options:
  -h, --help     Show this help message
  -l, --list     List all available tests

Arguments:
  TEST_NAME      Run only the specified test (without .sh extension)
                 Example: $0 help_flag

Examples:
  $0                    # Run all tests
  $0 --list            # List available tests
  $0 help_flag         # Run only the help_flag test
  $0 autodetect_git    # Run only the autodetect_git test

EOF
  exit 0
}

validate_test_coverage() {
  # Get all test files in cases/ directory
  local all_tests=()
  while IFS= read -r file; do
    local basename="$(basename "$file" .sh)"
    all_tests+=("$basename")
  done < <(find "$SCRIPT_DIR/cases" -name "*.sh" -type f | sort)
  
  # Get tests listed in test_list.txt
  local listed_tests=()
  while IFS= read -r test_name || [ -n "$test_name" ]; do
    [[ "$test_name" =~ ^#.*$ ]] && continue
    [[ -z "$test_name" ]] && continue
    listed_tests+=("$test_name")
  done < "$SCRIPT_DIR/test_list.txt"
  
  # Find unlisted tests (test files not in list)
  local unlisted=()
  for test in "${all_tests[@]}"; do
    local found=0
    for listed in "${listed_tests[@]}"; do
      if [[ "$test" == "$listed" ]]; then
        found=1
        break
      fi
    done
    if [[ $found -eq 0 ]]; then
      unlisted+=("$test")
    fi
  done
  
  # Find missing tests (listed tests without files)
  local missing=()
  for listed in "${listed_tests[@]}"; do
    local found=0
    for test in "${all_tests[@]}"; do
      if [[ "$test" == "$listed" ]]; then
        found=1
        break
      fi
    done
    if [[ $found -eq 0 ]]; then
      missing+=("$listed")
    fi
  done
  
  # Print warnings
  local has_issues=0
  
  if [[ ${#unlisted[@]} -gt 0 ]]; then
    echo -e "${YELLOW}[WARNING]${NC} Found ${#unlisted[@]} test file(s) not in test_list.txt:"
    for test in "${unlisted[@]}"; do
      echo -e "  ${YELLOW}✗${NC} $test"
    done
    echo ""
    echo "Add these to test_list.txt to include them in the test run."
    echo ""
    has_issues=1
  fi
  
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo -e "${RED}[ERROR]${NC} Found ${#missing[@]} test(s) in test_list.txt without corresponding files:"
    for test in "${missing[@]}"; do
      echo -e "  ${RED}✗${NC} $test (expected: cases/$test.sh)"
    done
    echo ""
    echo "Either create these test files or remove them from test_list.txt."
    echo ""
    has_issues=1
  fi
}

list_tests() {
  validate_test_coverage
  
  echo -e "${BLUE}Available tests:${NC}"
  echo ""
  local num=1
  while IFS= read -r test_name || [ -n "$test_name" ]; do
    [[ "$test_name" =~ ^#.*$ ]] && continue
    [[ -z "$test_name" ]] && continue
    
    # Only list tests that actually exist
    if [ -f "$SCRIPT_DIR/cases/${test_name}.sh" ]; then
      echo -e "  ${YELLOW}$num.${NC} $test_name"
      num=$((num + 1))
    fi
  done < "$SCRIPT_DIR/test_list.txt"
  echo ""
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      ;;
    -l|--list)
      list_tests
      ;;
    *)
      SPECIFIC_TEST="$1"
      shift
      ;;
  esac
done

# Create test directory
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

print_test() {
  echo -e "${YELLOW}[TEST $TEST_NUMBER]${NC} $1"
}

pass() {
  echo -e "${GREEN}[PASS]${NC} $1"
  PASSED=$((PASSED + 1))
}

fail() {
  echo -e "${RED}[FAIL]${NC} $1"
  FAILED=$((FAILED + 1))
}

cleanup() {
  cd /
  rm -rf "$TEST_DIR"
}

trap cleanup EXIT

# Read test list and execute tests
if [ -n "$SPECIFIC_TEST" ]; then
  echo "Running specific test: $SPECIFIC_TEST"
  echo ""
  
  TEST_FILE="$SCRIPT_DIR/cases/${SPECIFIC_TEST}.sh"
  
  if [ ! -f "$TEST_FILE" ]; then
    echo -e "${RED}[ERROR]${NC} Test file not found: $TEST_FILE"
    echo ""
    echo "Available tests:"
    list_tests
  fi
  
  TEST_NUMBER=1
  source "$TEST_FILE"
  run_test
else
  # Validate test coverage before running
  validate_test_coverage
  
  echo "Running Bear Make Tests..."
  echo ""
  
  # Load and run tests from test_list.txt
  while IFS= read -r test_name || [ -n "$test_name" ]; do
    # Skip comments and empty lines
    [[ "$test_name" =~ ^#.*$ ]] && continue
    [[ -z "$test_name" ]] && continue
    
    TEST_FILE="$SCRIPT_DIR/cases/${test_name}.sh"
    
    if [ ! -f "$TEST_FILE" ]; then
      echo -e "${RED}[ERROR]${NC} Test file not found: $TEST_FILE"
      FAILED=$((FAILED + 1))
      continue
    fi
    
    # Increment test number
    TEST_NUMBER=$((TEST_NUMBER + 1))
    
    # Source the test file and run it
    source "$TEST_FILE"
    run_test
    
    # Unset the run_test function to avoid conflicts
    unset -f run_test
  done < "$SCRIPT_DIR/test_list.txt"
fi

# Summary
echo ""
echo "================================"
echo -e "${GREEN}PASSED: $PASSED${NC}"
echo -e "${RED}FAILED: $FAILED${NC}"
echo "================================"

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed.${NC}"
  exit 1
fi
