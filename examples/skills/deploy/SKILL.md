---
name: deploy
description: Guides a manual deployment process with pre-flight checks, step-by-step execution, and post-deploy verification.
disable-model-invocation: true
allowed-tools: Bash(git status), Bash(git log *), Read, Grep
---

# Deploy Guide

This skill is **manual-only** (`disable-model-invocation: true`). Claude will never trigger this automatically. You must explicitly invoke it with `/deploy`.

## Target Environment

$ARGUMENTS

If no environment is specified, defaults to `staging`.

## Pre-flight Checks

Before deploying, verify:

1. **Branch status**: You are on the correct branch and it is clean
2. **Tests passing**: All CI checks are green
3. **No active incidents**: Check the status page before deploying
4. **Diff review**: Review the changes that will be deployed

Show the user the results of each check before proceeding.

## Deployment Steps

Present these steps to the user for manual execution. **Do not execute deployment commands directly.**

1. Tag the release: `git tag -a v{version} -m "Release v{version}"`
2. Push the tag: `git push origin v{version}`
3. Monitor the deployment pipeline
4. Verify health checks pass

## Post-deploy Verification

After the user confirms deployment is complete:

1. Check application health endpoints
2. Verify key user flows work
3. Monitor error rates for 15 minutes
4. Report deploy status

## Safety Rules

- **NEVER** run destructive commands (force push, database drops, etc.)
- **NEVER** execute deploy commands without explicit user confirmation for each step
- **ALWAYS** show what will happen before it happens
- If anything looks wrong, **STOP** and alert the user
