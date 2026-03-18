---
name: pr-summary
description: Analyzes the current pull request and generates a structured summary with metrics, review checklist, and risk assessment.
argument-hint: [pr-number]
allowed-tools: Read, Glob, Grep, Bash(git *), Bash(gh *)
context: fork
agent: Explore
---

# PR Summary Generator

Generate a comprehensive pull request summary.

## PR Target

!`if [ -n "$ARGUMENTS" ]; then echo "PR #$ARGUMENTS"; else echo "Current branch: $(git branch --show-current)"; fi`

## Context

### Changed Files
!`git diff --name-only HEAD~1 2>/dev/null || git diff --name-only main...HEAD 2>/dev/null || echo "No changes detected"`

### Diff Stats
!`git diff --stat HEAD~1 2>/dev/null || git diff --stat main...HEAD 2>/dev/null || echo "No stats available"`

### PR Metrics
!`bash ${CLAUDE_SKILL_DIR}/scripts/collect-metrics.sh 2>/dev/null || echo "Metrics script not available"`

## Instructions

1. Analyze the diff to understand what changed and why
2. Use the review checklist at `${CLAUDE_SKILL_DIR}/review-checklist.md` as a reference
3. Generate a summary in the following format:

## Output Format

```markdown
## Summary
[1-3 sentence overview of what this PR does]

## Changes
- [Categorized list of changes: Added / Changed / Removed / Fixed]

## Metrics
| Metric | Value |
|--------|-------|
| Files changed | N |
| Lines added | +N |
| Lines removed | -N |
| Test coverage | N% (if available) |

## Risk Assessment
- **Risk Level**: Low / Medium / High
- **Reason**: [Why this risk level]
- **Areas to watch**: [Specific files or patterns to review carefully]

## Review Checklist
- [ ] [Auto-generated checklist items based on changes]
```
