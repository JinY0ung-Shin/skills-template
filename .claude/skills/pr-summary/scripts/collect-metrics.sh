#!/bin/bash
# collect-metrics.sh
# Collects basic PR metrics from git history.
# Called by pr-summary skill via !`command` dynamic context injection.

set -euo pipefail

# Determine the base branch
BASE_BRANCH="${1:-main}"
CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || echo 'HEAD')"

# Files changed
FILES_CHANGED=$(git diff --name-only "${BASE_BRANCH}...${CURRENT_BRANCH}" 2>/dev/null | wc -l | tr -d ' ')

# Lines added/removed
DIFF_STATS=$(git diff --numstat "${BASE_BRANCH}...${CURRENT_BRANCH}" 2>/dev/null)
LINES_ADDED=$(echo "$DIFF_STATS" | awk '{sum += $1} END {print sum+0}')
LINES_REMOVED=$(echo "$DIFF_STATS" | awk '{sum += $2} END {print sum+0}')

# Commits count
COMMITS=$(git log --oneline "${BASE_BRANCH}...${CURRENT_BRANCH}" 2>/dev/null | wc -l | tr -d ' ')

# File types changed
FILE_TYPES=$(git diff --name-only "${BASE_BRANCH}...${CURRENT_BRANCH}" 2>/dev/null \
  | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -5 \
  | awk '{printf "%s (%d), ", $2, $1}' | sed 's/, $//')

cat <<EOF
Files changed: ${FILES_CHANGED}
Lines added: +${LINES_ADDED}
Lines removed: -${LINES_REMOVED}
Commits: ${COMMITS}
Top file types: ${FILE_TYPES:-none}
EOF
