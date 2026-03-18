---
name: my-skill
description: Performs a specific task with tool access and argument support.

# Hint shown in autocomplete when user types /my-skill
# Example: [file-path] [options], <required-arg>, [optional-arg]
argument-hint: <file-path> [options]

# Tools Claude can use without per-use approval while this skill is active.
# Supports wildcards: Bash(git *), Bash(npm:*), mcp__server-name__*
# Keep this as minimal as possible (least privilege principle).
allowed-tools: Read, Glob, Grep, Bash(git *)

# Override the model for this skill. Use for cost/speed optimization.
# Examples: haiku (fast/cheap), sonnet (balanced), opus (deep analysis)
# Omit to inherit the session's current model.
# model: haiku
---

# My Skill

Brief description of what this skill does.

## Target

- Primary argument: `$0`
- Secondary argument (optional): `$1`

You can also use `$ARGUMENTS` to access all arguments as a single string.

## Instructions

1. Step one
2. Step two
3. Step three

## Output Format

Describe the expected output format here.
