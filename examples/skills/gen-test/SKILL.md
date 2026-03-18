---
name: gen-test
description: Generates unit tests for the specified file or function, using the project's existing test framework and conventions.
argument-hint: <file-path> [function-name]
allowed-tools: Read, Glob, Grep, Write, Bash(npm test *), Bash(npx jest *), Bash(pytest *), Bash(go test *)
model: haiku
---

# Generate Tests

Generate unit tests for the specified target.

## Target

- File: `$0`
- Function (optional): `$1`

## Instructions

1. Read the target file and understand its exports/public API
2. Identify the project's test framework by checking:
   - `package.json` for JS/TS (jest, vitest, mocha)
   - `pyproject.toml` / `setup.cfg` for Python (pytest, unittest)
   - `go.mod` for Go (testing package)
3. Find existing tests to match the project's conventions:
   - File naming pattern (e.g., `*.test.ts`, `*_test.go`, `test_*.py`)
   - Import style, assertion library, mocking approach
4. Generate tests covering:
   - Happy path for each public function
   - Edge cases (empty input, null, boundary values)
   - Error cases (invalid input, expected exceptions)
5. Write the test file next to the source or in the project's test directory
6. Run the tests to verify they pass

## Rules

- Follow the project's existing test patterns exactly
- Do not modify the source file
- Use descriptive test names that explain the scenario
