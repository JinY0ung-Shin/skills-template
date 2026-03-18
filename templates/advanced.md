---
name: my-skill
description: Performs a complex task using subagent execution, dynamic context, hooks, and supporting files.
argument-hint: <target> [options]
allowed-tools: Read, Write, Glob, Grep, Bash(*)

# Run this skill in an isolated subagent context.
# The skill content becomes the subagent's task prompt.
# Claude's conversation history is NOT available inside the fork.
context: fork

# Which subagent type to use (only meaningful when context: fork).
# Built-in options: general-purpose (default), Explore, Plan
# You can also use custom agent names defined in .claude/agents/
agent: general-purpose

# Override model for this skill.
# model: sonnet

# Prevent Claude from auto-invoking this skill.
# When true, only the user can invoke via /my-skill.
# The skill's description is removed from Claude's context entirely.
# disable-model-invocation: true

# Hide from the / menu. Only Claude can invoke this skill.
# Useful for background knowledge or internal-use skills.
# user-invocable: false

# Skill-scoped lifecycle hooks.
hooks:
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/scripts/pre-check.sh"
          once: true
---

# My Skill

Brief description of what this skill does.

## Dynamic Context

Inject live data using shell preprocessing. Claude only sees the output, not the commands.

### Current State
!`echo "Branch: $(git branch --show-current 2>/dev/null || echo 'N/A')"`
!`echo "Last commit: $(git log --oneline -1 2>/dev/null || echo 'N/A')"`

## Target

- Primary: `$0`
- Options: `$1`
- All args: `$ARGUMENTS`

## Supporting Files

This skill uses supporting files in the same directory:

- **Checklist**: See `${CLAUDE_SKILL_DIR}/checklist.md` for the review checklist
- **Scripts**: Run `${CLAUDE_SKILL_DIR}/scripts/pre-check.sh` for validation

Keep SKILL.md under 500 lines. Move detailed references to separate files.

## Instructions

1. Step one
2. Step two
3. Step three

## Output Format

Describe the expected output format here.
