---
# [Required for cross-tool compatibility] Skill name.
# Rules: max 64 chars, lowercase + numbers + hyphens only.
# Cannot contain "anthropic" or "claude". Must match directory name.
name: my-skill

# [Required for cross-tool compatibility] What this skill does.
# Rules: max 1024 chars, third person ("Processes..." not "I can..."), no XML tags.
# Claude uses this to decide when to auto-invoke the skill.
description: Performs a specific task when invoked by the user or Claude.
---

# My Skill

Brief description of what this skill does.

## Target

$ARGUMENTS

## Instructions

1. Step one
2. Step two
3. Step three

## Output Format

Describe the expected output format here.
