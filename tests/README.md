# Bear Make Test Suite

## Structure

The test suite has been refactored into a modular structure for easier maintenance:

```
tests/
├── test_bear_make.sh      # Main test runner
├── test_list.txt          # Defines test execution order
├── cases/                 # Individual test case files
│   ├── help_flag.sh
│   ├── autodetect_makefile.sh
│   ├── autodetect_git.sh
│   └── ... (20 test files total)
└── README.md
```

## How It Works

1. **test_bear_make.sh** - Main test runner that:
   - Sets up the test environment
   - Reads test names from `test_list.txt`
   - Sources and executes each test file
   - Auto-numbers tests during runtime
   - Provides summary of results

2. **test_list.txt** - Simple text file listing test names (one per line):
   - Lines starting with `#` are comments
   - Blank lines are ignored
   - Tests run in the order listed
   - No manual numbering required!

3. **cases/*.sh** - Individual test files:
   - Each file contains one test case
   - Defines a `run_test()` function
   - Uses shared helper functions: `print_test()`, `pass()`, `fail()`
   - Access to environment variables: `$TEST_DIR`, `$BEAR_MAKE`, etc.

## Adding a New Test

Adding a new test is simple:

1. **Create a test file** in `cases/`:
   ```bash
   cat > cases/my_new_test.sh <<'EOF'
   #!/usr/bin/env bash
   # Test: Description of what this tests
   
   run_test() {
     print_test "My new test description"
     # ... test logic ...
     if [ condition ]; then
       pass "Test passed"
     else
       fail "Test failed"
     fi
   }
   EOF
   ```

2. **Add it to test_list.txt**:
   ```
   # Add the filename (without .sh) wherever you want it to run
   help_flag
   my_new_test    # <-- Add here
   autodetect_makefile
   ```

3. **Done!** The test will be automatically numbered at runtime.

## Benefits

- **No manual numbering**: Tests are numbered automatically during execution
- **Easy reordering**: Just change the order in `test_list.txt`
- **Easy to add/remove**: No need to renumber other tests
- **Better organization**: Each test is in its own file
- **Easier debugging**: Can run individual tests by sourcing them
- **Coverage validation**: Warns if any test files are not in `test_list.txt`

## Running Tests

### Show help:
```bash
./test_bear_make.sh --help
./test_bear_make.sh -h
```

### List all available tests:
```bash
./test_bear_make.sh --list
./test_bear_make.sh -l
```

### Run all tests:
```bash
./test_bear_make.sh
```

### Run a specific test:
```bash
./test_bear_make.sh help_flag
./test_bear_make.sh autodetect_makefile
./test_bear_make.sh symbolic_links
# etc.
```

## Test Coverage Validation

When running all tests (no arguments), the script automatically validates the test suite:

### 1. Detects Orphaned Test Files
Test files that exist in `cases/` but are not in `test_list.txt`:
```
[WARNING] Found 1 test file(s) not in test_list.txt:
  ✗ my_forgotten_test

Add these to test_list.txt to include them in the test run.
```

### 2. Detects Missing Test Files
Tests listed in `test_list.txt` that don't have corresponding files:
```
[ERROR] Found 2 test(s) in test_list.txt without corresponding files:
  ✗ nonexistent_test (expected: cases/nonexistent_test.sh)
  ✗ another_missing (expected: cases/another_missing.sh)

Either create these test files or remove them from test_list.txt.
```

Missing test files are counted as **failures** and will cause the test suite to exit with error code 1.

### Benefits
- Prevents forgetting to add new tests to the list (orphaned files)
- Catches typos or deleted files (missing files)
- Ensures test list accuracy
- Keeps test suite clean and complete

Note: Orphaned tests can still be run individually:
```bash
./test_bear_make.sh my_forgotten_test
```

## Available Helper Functions

Tests have access to these functions:

- `print_test "message"` - Print test header
- `pass "message"` - Mark test as passed
- `fail "message"` - Mark test as failed

## Available Variables

- `$BEAR_MAKE` - Path to the bear_make script
- `$TEST_DIR` - Temporary test directory
- `$SCRIPT_DIR` - Path to the tests directory
- `$TEST_NUMBER` - Current test number (auto-incremented)
- `$PASSED` - Count of passed tests
- `$FAILED` - Count of failed tests
