---
name: review
description: Reviews code changes in the current branch and provides structured feedback on correctness, style, and potential issues.
---

# Code Review

Review the code changes and provide structured feedback.

## Target

$ARGUMENTS

If no target is specified, review all uncommitted changes.

## Review Process

1. Identify the changed files and understand the context
2. For each change, evaluate:
   - **Correctness**: Logic errors, edge cases, off-by-one errors
   - **Style**: Naming conventions, code organization, readability
   - **Security**: Input validation, injection risks, secrets exposure
   - **Performance**: Unnecessary allocations, N+1 queries, missing indexes

## Output Format

For each issue found:

```
[SEVERITY] file:line - description
  Suggestion: how to fix
```

Severity levels: `CRITICAL` > `MAJOR` > `MINOR` > `NIT`

End with a summary:
```
Summary: X issues found (N critical, N major, N minor, N nit)
Verdict: APPROVE / REQUEST_CHANGES
```
