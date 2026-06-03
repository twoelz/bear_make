# bear_make

**bear_make** generates a [clang compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) (`compile_commands.json`) using Bear (<https://github.com/rizsotto/Bear>) to intercept compiler calls during a make build primarily for a C/C++ project. It wraps the `bear -- make` command with automatic options, root/output detection, and validations, so you get the compilation database with minimal setup—useful for tooling that relies on it (e.g. clangd, clang-tidy, ccls).

## Features

- **Auto-detection of project root** — Walks up from the current directory to find a Makefile or `.git` (Makefile is preferred).
- **Automatic clean build** — Runs `make clean` first so Bear captures *all* compilation commands (disable with `--no-clean`).
- **Sensible defaults** — Writes `<project_root>/compile_commands.json` and runs `make all`.
- **Safety checks** — Verifies Bear is installed and that the output directory exists and is writable.
- **Flexibility** — Custom root, output path, make arguments, and full Bear flags via `--flags`.
- **Portable `compile_commands.json`** — After Bear runs, paths in the database are normalized so the file is easier to reuse on another machine or checkout path (e.g. shared clusters): each entry’s `"directory"` is `"."`, source paths under the project root are relative to that root, and common system compilers are recorded as bare names (`g++`, `gcc`, …) instead of `/usr/bin/...`.
- **Optional clangd config (`--clangd`)** — Can write a `.clangd` beside the output database so clangd uses that subproject’s `compile_commands.json` (useful when several databases live in one workspace).

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
| `--clangd` | Write a `.clangd` file next to the output `compile_commands.json` if one is not already there (see [clangd and multiple subprojects](#clangd-and-multiple-subprojects)). |
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
bear_make --clangd                           # Also write .clangd for clangd
```

## clangd and multiple subprojects

If you open a **parent workspace** that contains several independent C/C++ subprojects, each with its own `compile_commands.json`, clangd walks upward from the file you edit and may pick the **wrong** database (a sibling’s or the repo root’s).

Run `bear_make` from **each subproject root** (or pass `--root` / `-o` for that subproject). After generating the database, add a `.clangd` file **in the same directory** as that subproject’s `compile_commands.json`:

```yaml
CompileFlags:
  CompilationDatabase: .
```

The `.` path is relative to the folder that contains `.clangd`, so clangd uses that subproject’s `compile_commands.json` for files under that tree.

Use **`--clangd`** to create that file automatically when it does not exist yet; an existing `.clangd` is never overwritten. This pairs well with bear_make’s portable `"directory": "."` entries: keep the database and `.clangd` together at the subproject root.

## Notes

- If you pass `--output` inside `--flags`, do not also use the script’s `-o`/`--output`; using both is an error.
- The **output file** location (`-o` / `--output`, or `--output` inside `--flags`) may be absolute or relative to the project root; that only controls where `compile_commands.json` is written.
- The **contents** of the generated database are post-processed for portability: `"directory"` is set to `"."`, absolute paths under the detected project root are stripped from file and command strings, and `/usr/bin/{c++,g++,cc,gcc}` are rewritten to the bare compiler names. Run your editor or analyzer with the project root as the working directory (or paths that match how you use `"directory": "."`) so tools resolve sources correctly.
- The script uses `set -euo pipefail`; failures in Bear or make will cause the script to exit with a non-zero status.

## Testing

The test suite lives under `tests/`. See [tests/README.md](tests/README.md) for how to run tests and add new ones.
