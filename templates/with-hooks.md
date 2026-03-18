---
name: my-skill
description: Performs a specific task with lifecycle hooks for safety or automation.
allowed-tools: Read, Write, Glob, Grep, Bash(*)

# Skill-scoped hooks: active only while this skill is running.
# Common events: PreToolUse, PostToolUse, Stop (see docs for full list)
hooks:
  # Runs BEFORE a tool is used. Return exit code 2 to block the tool call.
  PreToolUse:
    - matcher: Bash        # Which tool to intercept (exact name or pattern)
      hooks:
        - type: command
          command: "echo 'Pre-check for Bash command'"
          # once: true      # Uncomment to run only once per session (skills-only feature)

  # Runs AFTER a tool completes. Useful for logging or cleanup.
  # PostToolUse:
  #   - matcher: Write
  #     hooks:
  #       - type: command
  #         command: "echo 'File was written'"

  # Runs when the skill finishes (or Claude stops).
  # Stop:
  #   - hooks:
  #       - type: command
  #         command: "echo 'Skill session ended'"
---

# My Skill

Brief description of what this skill does.

## Target

$ARGUMENTS

## Instructions

1. Step one (hook runs automatically before first Bash command)
2. Step two
3. Step three

## Output Format

Describe the expected output format here.
