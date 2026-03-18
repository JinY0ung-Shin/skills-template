---
name: secure-ops
description: Performs file operations with automatic security scanning before any shell command execution.
allowed-tools: Read, Write, Glob, Grep, Bash(*)
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/scripts/security-check.sh"
          once: true
---

# Secure Operations

This skill wraps file operations with automatic security checks.

The `hooks` in frontmatter define a **PreToolUse** hook that runs `security-check.sh` before any Bash command. The `once: true` flag means the check runs only once per session, not before every single command.

## What the Hook Does

Before the first Bash command in this skill's session:
1. Scans the working directory for common security issues
2. Checks for exposed secrets (API keys, tokens, passwords)
3. Verifies `.gitignore` covers sensitive files
4. Reports findings before allowing any commands to proceed

## Target

$ARGUMENTS

If no target is specified, operates on the current directory.

## Instructions

1. Run the security scan (happens automatically via hook on first Bash use)
2. Perform the requested file operation
3. After modifications, verify no secrets were accidentally introduced
4. Report the operation result and any security observations

## Security Principles

- **Least privilege**: Only request the tools you actually need
- **Audit trail**: Log what was checked and what was found
- **Fail safe**: If the security check fails, do not proceed with the operation
