# Quick Reference

## Common Commands

```bash
# Show help
./test_bear_make.sh --help

# List all available tests
./test_bear_make.sh --list

# Run all tests
./test_bear_make.sh

# Run a specific test
./test_bear_make.sh help_flag
./test_bear_make.sh symbolic_links
```

## Adding a New Test

1. Create test file:
   ```bash
   cat > cases/my_test.sh <<'EOF'
   #!/usr/bin/env bash
   # Test: What this tests
   
   run_test() {
     print_test "Description"
     # test logic here
     if [ condition ]; then
       pass "Success message"
     else
       fail "Failure message"
     fi
   }
   EOF
   ```

2. Add to `test_list.txt`:
   ```bash
   echo "my_test" >> test_list.txt
   ```

3. Run it:
   ```bash
   ./test_bear_make.sh my_test
   ```

Done! No numbering needed.
