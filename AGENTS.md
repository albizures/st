# Odin AST Project - Agent Guidelines

Welcome to the Odin ST (Syntax Tree). This guide provides AI coding agents and human contributors with essential workflows, commands, and project conventions to ensure consistent, high-quality development. Read this file completely before editing code.

## 1. Build, Lint, and Test Commands

This project is a **monorepo with multiple packages**. Each top-level folder (e.g., `ast`, `lines`, `pos`, `tokenizer`) is a different package, containing its own `src` and (sometimes) `test` subdirectories or `main.odin`.

### Building
To build a specific module, point Odin to the directory containing its `main.odin` or source files:
```bash
# Build the tokenizer
odin build ./tokenizer

# Type-check a module without emitting an executable
odin check ./tokenizer
```
**Important:** We do not have a top-level `main.odin`. Operations are performed per-package.

### Testing
We use Odin's built-in `core:testing` package.
- **Run all tests in a module:**
  ```bash
  odin test ./tokenizer/test
  ```
- **Run tests for all modules:**
  You generally run tests per package since Odin requires a directory of test files. To run tests in multiple modules, you must execute `odin test` separately for each module's test directory.
- **Run a single test function:**
  You can filter tests by name using the `-test-name` flag (if your Odin version supports it). 
  ```bash
  odin test ./tokenizer/test -test-name:test_advance_rune
  ```

### Linting & Formatting
- **Type Checking (Linting):** Rely on `odin check <dir>` to catch type errors, undefined variables, and basic syntax issues before running tests. This is your primary linting tool. Always run this before committing or concluding a task!
- **Formatting:** Try to mirror the exact indentation (tabs/spaces) of the existing code. If `odinfmt` is installed, use it (`odinfmt -w <file>`); otherwise, manually mimic the file's current style. Use tabs for indentation.

## 2. Code Style Guidelines

### Naming Conventions
- **Procedures, Variables, and Packages:** `snake_case`
  - Examples: `create_tokenizer`, `advance_rune`, `tokenizer_core`, `index`
- **Types (Structs, Enums, Unions):** `Ada Case`
  - Examples: `Tokenizer`, `My_Struct`
- **Constants:** `UPPER_SNAKE_CASE`
  - Examples: `CUSTOM_OFFSET`

### Types & Data Structures
- Favor explicit structs and distinct types for clear semantic boundaries (e.g., `Kind :: distinct u32`).
- Use Odin's built-in numeric/string types and `core:unicode/utf8` for rune manipulation.
- Utilize slices `[]T` instead of dynamic arrays `[dynamic]T` if sizes are known or if you just need a view into existing memory. 

### Imports
- **Grouping:** Group standard library imports (`core:`) together.
- **Relative paths:** Use relative imports for internal modules (e.g., `import "../../pos"`, `import src "../src"`).
- **Test Aliasing:** In tests, alias the module being tested for clarity. For example: `import src "../src"`.

### Testing Style
- **Prefixes:** Prefix test procedures with `@(test)`.
- **Context:** Use the `testing.T` context pointer: `proc(t: ^testing.T)`.
- **Assertions:** Use `testing.expect_value(t, actual, expected)` for assertions. Do not use panics for test checks.
- **Naming:** Test files must be named `*.test.odin`.

### Error Handling & Pointers
- **No Panics:** Avoid panics unless absolutely necessary for unrecoverable system states.
- **Return Values:** Return multiple values (e.g., `value, ok`) or default values (e.g., `utf8.RUNE_EOF`) when handling bounds or end-of-file scenarios. This is idiomatic Odin.
- **Pointers vs Values:** 
  - Procedures modifying a struct state MUST take a pointer: `proc(t: ^Tokenizer)`.
  - Read-only procedures should take by value if small (e.g., `proc(t: pos.Span)`), or pointer if large: `proc(t: ^Tokenizer)` or `proc(t: Tokenizer)`.

### Memory Management
- **No GC:** Odin does not use a garbage collector. Be extremely mindful of allocations.
- **Memory Tracking in Tests:** Tests automatically enable memory tracking (`testing` package). Ensure you do not leave memory leaks. If a test fails with "Free/Alloc" mismatch, find the leaked memory.
- **Context Allocators:** If a procedure allocates memory, consider allowing the caller to pass an explicit allocator or rely on the implicit `context.allocator`.
- **Temporary Allocator:** Use `context.temp_allocator` for short-lived allocations that are cleared per-frame or per-iteration.

By strictly adhering to these rules, you keep the Odin AST modules fast, safe, and maintainable.
