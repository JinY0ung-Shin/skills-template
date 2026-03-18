#!/bin/bash
# security-check.sh
# Pre-flight security scan run by the secure-ops skill's PreToolUse hook.
# Exits 0 if safe, exits 1 if issues found (blocks the Bash command).

set -euo pipefail

ISSUES=0
REPORT=""

add_issue() {
  ISSUES=$((ISSUES + 1))
  REPORT="${REPORT}\n  [ISSUE ${ISSUES}] $1"
}

echo "=== Security Pre-flight Check ==="

# 1. Check for common secret patterns in staged/modified files
SECRETS_PATTERN='(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|password\s*=\s*["\x27][^"\x27]+["\x27])'
MODIFIED_FILES=$(git diff --name-only HEAD 2>/dev/null || find . -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.go' | head -50)

if [ -n "$MODIFIED_FILES" ]; then
  FOUND=$(echo "$MODIFIED_FILES" | xargs grep -lE "$SECRETS_PATTERN" 2>/dev/null || true)
  if [ -n "$FOUND" ]; then
    add_issue "Potential secrets found in: ${FOUND}"
  fi
fi

# 2. Check .gitignore covers sensitive files
for SENSITIVE in ".env" ".env.local" "credentials.json" "*.pem" "*.key"; do
  if [ -f ".gitignore" ]; then
    if ! grep -q "$SENSITIVE" .gitignore 2>/dev/null; then
      if find . -name "$SENSITIVE" -not -path './.git/*' 2>/dev/null | grep -q .; then
        add_issue "${SENSITIVE} exists but is not in .gitignore"
      fi
    fi
  fi
done

# 3. Check for overly permissive file permissions
WORLD_READABLE=$(find . -maxdepth 2 -name '*.key' -o -name '*.pem' -o -name '.env*' 2>/dev/null \
  | xargs -r stat -c '%a %n' 2>/dev/null \
  | awk '$1 > 600 {print $2}' || true)
if [ -n "$WORLD_READABLE" ]; then
  add_issue "Overly permissive files: ${WORLD_READABLE}"
fi

# Report results
if [ "$ISSUES" -gt 0 ]; then
  echo -e "FAILED: ${ISSUES} issue(s) found${REPORT}"
  echo ""
  echo "Fix these issues before proceeding."
  # Exit code 2 tells Claude Code PreToolUse hooks to BLOCK the tool call.
  # Exit code 1 = hook error (does not block), exit code 2 = deny.
  exit 2
else
  echo "PASSED: No security issues detected."
  exit 0
fi
