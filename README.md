# Agent Skills Template

A comprehensive template repository for creating [Agent Skills](https://agentskills.io). Learn by example, copy templates, and build your own.

> This repo follows the open [Agent Skills](https://agentskills.io) standard, with examples of Claude Code-specific extension fields for tool permissions, model overrides, subagent execution, and lifecycle hooks.

## What is a Skill?

A skill is a reusable prompt packaged as a `SKILL.md` file that an agent can invoke (or users can trigger with `/skill-name`). Each skill lives in its own directory with optional scripts, reference docs, and static assets.

```
.claude/skills/my-skill/
├── SKILL.md              # Main instructions (required)
├── scripts/              # Executable code (optional)
│   └── validate.sh
├── references/           # Additional documentation (optional)
│   └── REFERENCE.md
└── assets/               # Static resources (optional)
    └── template.json
```

### Optional Directories

The [Agent Skills standard](https://agentskills.io/specification) defines three optional directories:

| Directory | Purpose | Examples |
|-----------|---------|----------|
| `scripts/` | Executable code that the agent can run | Shell scripts, Python scripts, validators |
| `references/` | Additional documentation loaded on demand | Technical references, checklists, form templates |
| `assets/` | Static resources | Document templates, schemas, lookup tables |

These files are **never preloaded** — the agent reads them only when the skill is invoked and needs them (progressive disclosure). Reference from SKILL.md using `${CLAUDE_SKILL_DIR}`:

```markdown
Run the validation script:
!`bash ${CLAUDE_SKILL_DIR}/scripts/validate.sh`

See [the checklist](${CLAUDE_SKILL_DIR}/references/checklist.md) for details.
```

> Keep file references one level deep from SKILL.md. Avoid deeply nested reference chains. For full details, see [REFERENCE.md § Directory Structure](REFERENCE.md#directory-structure).

## Quick Start

### 1. Create a skill directory

```bash
mkdir -p .claude/skills/my-skill
```

### 2. Create SKILL.md

```markdown
---
name: my-skill
description: Performs a specific task when invoked.
---

# My Skill

Do something with: $ARGUMENTS
```

### 3. Use it

```
/my-skill hello world
```

Or let the agent auto-invoke it based on the description.

## SKILL.md Format

Every skill is a Markdown file with YAML frontmatter. The Agent Skills spec requires `name` and `description`; this repo always includes them for standards compliance and cross-tool portability.

```yaml
---
name: my-skill                      # [core] Slash command name
description: Does something useful.  # [core] What it does (third person)
argument-hint: <file> [options]      # [ext]  Autocomplete hint
allowed-tools: Read, Grep, Bash(git *)  # [CLI-only] Tools without approval
model: haiku                         # [ext]  Model override
context: fork                        # [ext]  Isolated subagent execution
agent: Explore                       # [ext]  Subagent type (with fork)
disable-model-invocation: true       # [ext]  User-only invocation
user-invocable: false                # [ext]  Claude-only invocation
hooks:                               # [ext]  Lifecycle hooks
  PreToolUse:
    - matcher: Bash
      hooks:
        - type: command
          command: "./scripts/check.sh"
---

# Skill content (Markdown)
```

### Frontmatter Fields Summary

| Field | Label | Description |
|-------|-------|-------------|
| `name` | `[core]` | Slash command name (required for spec compliance) |
| `description` | `[core]` | What the skill does, in third person (required for spec compliance) |
| `argument-hint` | `[ext]` | Autocomplete hint shown to users |
| `allowed-tools` | `[CLI-only]` | Tools the agent can use without per-use approval |
| `model` | `[ext]` | Override the model for this skill |
| `context` | `[ext]` | Set to `fork` for isolated subagent execution |
| `agent` | `[ext]` | Subagent type when using `context: fork` |
| `disable-model-invocation` | `[ext]` | `true` = user-only, Claude cannot auto-invoke |
| `user-invocable` | `[ext]` | `false` = Claude-only, hidden from `/` menu |
| `hooks` | `[ext]` | Lifecycle hooks scoped to the skill's duration |

Labels: `[core]` = Agent Skills standard, `[ext]` = Claude Code extension, `[CLI-only]` = CLI only

> For the full field reference with types, defaults, and constraints, see [REFERENCE.md](REFERENCE.md).

## Variables

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments as a string |
| `$0`, `$1`, ... | Individual arguments (0-indexed) |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | This skill's directory path |

### Dynamic Context Injection

Use `` !`command` `` to inject shell output as preprocessing:

```markdown
## Current Branch
!`git branch --show-current`

## Changed Files
!`git diff --name-only main...HEAD`
```

The agent sees only the output, not the commands.

## Storage and Precedence

| Priority | Level | Path |
|:--------:|-------|------|
| 1 | Enterprise | Admin-managed settings |
| 2 | Personal | `~/.claude/skills/<name>/SKILL.md` |
| 3 | Project | `.claude/skills/<name>/SKILL.md` |

Plugin skills use a separate namespace (`plugin-name:skill-name`) and don't conflict with the above.

## Naming Rules

- Max **64 characters**, lowercase letters + numbers + hyphens only
- No leading/trailing hyphens, no consecutive hyphens (`--`)
- Directory name must match the `name` field
- **Claude Code only**: Cannot contain `"anthropic"` or `"claude"`

## Examples

This repo includes 6 example skills in [`examples/skills/`](examples/skills/) covering common patterns. These are placed outside `.claude/skills/` so they are **not loaded as active skills** — they are reference-only.

| Example | Pattern | Key Features |
|---------|---------|-------------|
| [`review`](examples/skills/review/) | Basic | Minimal frontmatter, `$ARGUMENTS` |
| [`gen-test`](examples/skills/gen-test/) | Tools + Args | `allowed-tools`, `argument-hint`, `$0`/`$1`, `model` override |
| [`pr-summary`](examples/skills/pr-summary/) | Advanced | `context: fork`, `agent`, `!`command``, supporting files, scripts |
| [`deploy`](examples/skills/deploy/) | Manual-only | `disable-model-invocation: true`, safe patterns for dangerous ops |
| [`legacy-context`](examples/skills/legacy-context/) | Claude-only | `user-invocable: false`, background knowledge |
| [`secure-ops`](examples/skills/secure-ops/) | Hooks | `hooks` (PreToolUse), `once: true`, security scripts |

## Templates

Copy a template to get started quickly:

| Template | Use When |
|----------|----------|
| [`basic.md`](templates/basic.md) | Simple skill with just name + description |
| [`with-tools.md`](templates/with-tools.md) | Need tool access, arguments, or model override |
| [`with-hooks.md`](templates/with-hooks.md) | Need lifecycle hooks (pre/post checks) |
| [`advanced.md`](templates/advanced.md) | Need everything: fork, agent, hooks, dynamic context |

```bash
# Copy a template to start a new skill
cp templates/basic.md .claude/skills/my-skill/SKILL.md
```

## Installation

To use an example skill in your project:

```bash
# Copy a single example skill
cp -r examples/skills/review/ /your/project/.claude/skills/

# Or copy all examples
cp -r examples/skills/* /your/project/.claude/skills/
```

## Cross-tool Compatibility

This repo always includes `name` and `description` in every skill for maximum portability across Agent Skills implementations. While Claude Code can infer defaults, other tools may not.

## Security

When using third-party skills:

- **Audit `scripts/`** for unexpected commands before using
- **Review `` !`command` ``** — dynamic context injection runs shell commands
- **Check `allowed-tools`** — understand what tools run without your approval
- **Review `hooks`** — PreToolUse/PostToolUse execute commands automatically
- Follow the **least privilege principle**: only grant tools the skill actually needs

## Resources

- [Agent Skills Specification](https://agentskills.io/specification)
- [Full Field Reference](REFERENCE.md) (this repo)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
