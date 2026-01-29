# bear_make

**bear_make** generates a [clang compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) (`compile_commands.json`) using Bear (<https://github.com/rizsotto/Bear>) to intercept compiler calls during a make build primarilyfor a C/C++ project. It wraps the `bear -- make` command with automatic options, root/output detection, and validations, so you get the compilation database with minimal setup—useful for tooling that relies on it (e.g. clangd, clang-tidy, ccls).

## Features

- **Auto-detection of project root** — Walks up from the current directory to find a Makefile or `.git` (Makefile is preferred).
- **Automatic clean build** — Runs `make clean` first so Bear captures *all* compilation commands (disable with `--no-clean`).
- **Sensible defaults** — Writes `<project_root>/compile_commands.json` and runs `make all`.
- **Safety checks** — Verifies Bear is installed and that the output directory exists and is writable.
- **Flexibility** — Custom root, output path, make arguments, and full Bear flags via `--flags`.

## Requirements

- **Bear** (<https://github.com/rizsotto/Bear>) — Install before use.  
  On Ubuntu/Debian: `sudo apt install bear`

## Usage

```text
bear_make [--root DIR] [--output FILE] [--no-clean] [--flags FLAGS] [--] [make args...]
```

### Options

| Option | Description |
|--------|-------------|
| `-r`, `--root DIR` | Project root directory (default: auto-detected). |
| `-o`, `--output FILE` | Output file path (default: `<root>/compile_commands.json`). |
| `--no-clean` | Skip `make clean` before the build. |
| `--flags FLAGS` | Extra flags for Bear (e.g. `"--append --verbose"`). Run `bear --help` for all options. |
| `-h`, `--help` | Show help and exit. |
| `--` | Separator: everything after is passed to `make`. |

### Defaults

- **Root:** Auto-detected by walking up from `$PWD` (prefers a directory with a Makefile, otherwise `.git`; falls back to `$PWD`).
- **Output:** `<root>/compile_commands.json`.
- **Build:** `make all`.
- **Clean:** `make clean` is run first unless `--no-clean` is used.

### Examples

```bash
bear_make                                    # Defaults: auto root, make all, clean first
bear_make --flags "--append"                 # Append to existing compile_commands.json
bear_make -- clean all                       # Pass "clean all" to make
bear_make --no-clean                         # Skip make clean
bear_make -o /tmp/cc.json                    # Custom output path
bear_make --root /path/to/project            # Explicit project root
bear_make --flags "--verbose" -- re          # Verbose Bear, make target "re"
```

## Notes

- If you pass `--output` inside `--flags`, do not also use the script’s `-o`/`--output`; using both is an error.
- Output path can be absolute or relative to the project root.
- The script uses `set -euo pipefail`; failures in Bear or make will cause the script to exit with a non-zero status.

## Testing

The test suite lives under `tests/`. See [tests/README.md](tests/README.md) for how to run tests and add new ones.
