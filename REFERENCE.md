# SKILL.md Frontmatter Reference

> Authoritative sources: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills), [Agent Skills Spec](https://agentskills.io/specification), [Claude Code Hooks Docs](https://code.claude.com/docs/en/hooks)

## Field Reference

Each field is labeled with its origin:
- **`[core]`** — Agent Skills open standard (cross-tool portable)
- **`[ext]`** — Claude Code extension (Claude Code only)
- **`[CLI-only]`** — Claude Code CLI only (not available in Agent SDK/API)
- **`[legacy]`** — Backward-compatible, superseded by newer approach

### Agent Skills Standard Fields

| Field | Type | Required | Default | Label | Description |
|-------|------|----------|---------|-------|-------------|
| `name` | string | Yes | — | `[core]` | Slash command name. Max 64 chars, lowercase + numbers + hyphens only. Cannot contain "anthropic" or "claude". No leading/trailing hyphens, no consecutive hyphens (`--`). Must match the containing directory name. |
| `description` | string | Yes | — | `[core]` | What the skill does. Max 1024 chars, third person ("Processes..." not "I can..."), no XML tags. Claude uses this to decide when to auto-invoke. |
| `license` | string | No | — | `[core]` | License reference for distributable skills. |
| `compatibility` | string | No | — | `[core]` | Required tools or dependencies. |
| `metadata` | map | No | — | `[core]` | Arbitrary string-to-string key-value pairs for tracking. |

> **Claude Code convenience**: Claude Code can infer `name` from the directory name and `description` from the first paragraph of content. However, the Agent Skills spec requires both fields for portable, standards-compliant skills. This repo always includes them explicitly.

### Claude Code Extension Fields

| Field | Type | Default | Label | Description |
|-------|------|---------|-------|-------------|
| `argument-hint` | string | — | `[ext]` | Hint shown in autocomplete. Example: `<file-path> [options]` |
| `disable-model-invocation` | boolean | `false` | `[ext]` | When `true`, only the user can invoke via `/name`. Removes description from Claude's context entirely. |
| `user-invocable` | boolean | `true` | `[ext]` | When `false`, hides from the `/` menu. Only Claude can invoke. |
| `allowed-tools` | string | — | `[CLI-only]` | Comma-separated tools Claude can use without per-use approval. Supports wildcards: `Bash(git *)`, `Bash(npm:*)`, `mcp__server__*`. |
| `model` | string | Session model | `[ext]` | Override model. See [Models Overview](https://docs.anthropic.com/en/docs/about-claude/models). |
| `context` | string | — | `[ext]` | Set to `fork` to run in an isolated subagent context. |
| `agent` | string | `general-purpose` | `[ext]` | Subagent type when `context: fork`. Built-in: `general-purpose`, `Explore`, `Plan`. Also supports custom agents from `.claude/agents/`. |
| `hooks` | object | — | `[ext]` | Skill-scoped lifecycle hooks. See [Hooks](#hooks-in-skills). |

---

## Invocation Control Matrix

How `disable-model-invocation` and `user-invocable` interact:

| `disable-model-invocation` | `user-invocable` | User can invoke | Claude can invoke | Description in context |
|:-:|:-:|:-:|:-:|:-:|
| `false` (default) | `true` (default) | Yes | Yes | Yes |
| `true` | `true` | Yes | No | **No** (removed entirely) |
| `false` | `false` | No | Yes | Yes |
| `true` | `false` | No | No | No (impractical) |

**Use cases:**
- **Default** — Normal skill, available to everyone
- **`disable-model-invocation: true`** — Dangerous operations (deploy, delete) that should only run on explicit user request
- **`user-invocable: false`** — Background knowledge or conventions that Claude should auto-apply but users don't need to invoke directly

---

## Progressive Disclosure

Skills use a lazy-loading architecture to minimize context window usage:

1. **Startup**: Only `name` and `description` from each skill (~100 tokens per skill) are loaded into the system prompt
2. **Invocation**: The full SKILL.md content is read from disk only when invoked
3. **Supporting files**: Scripts and reference files are accessed on-demand, never preloaded

### Description Budget

The total character budget for all skill descriptions is:
- **2% of the context window** (with a fallback of **16,000 characters**)
- Override with the `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable
- Run `/context` to check if any skills are being excluded due to budget overflow

### Skills excluded from discovery:
- `disable-model-invocation: true` (removed from Claude's context)
- Missing both `description` and content

---

## Naming Rules

| Rule | Example |
|------|---------|
| Max 64 characters | `my-awesome-skill` |
| Lowercase letters, numbers, hyphens only | `gen-test` (not `Gen_Test`) |
| Cannot contain "anthropic" or "claude" | `my-claude-helper` is invalid |
| No leading/trailing hyphens | `-my-skill` is invalid |
| No consecutive hyphens | `my--skill` is invalid |
| Directory name must match `name` field | `skills/gen-test/SKILL.md` → `name: gen-test` |

---

## Storage Locations and Precedence

### Precedence (higher wins)

| Priority | Level | Path | Scope |
|:--------:|-------|------|-------|
| 1 | Enterprise | Admin-managed settings | All users in the organization |
| 2 | Personal | `~/.claude/skills/<name>/SKILL.md` | All of your projects |
| 3 | Project | `.claude/skills/<name>/SKILL.md` | This project only |

### Plugin Skills (separate namespace)

Plugin skills use a `plugin-name:skill-name` namespace and **do not conflict** with the precedence chain above.

- Invocation: `/plugin-name:skill-name`
- Defined in: `<plugin>/skills/<name>/SKILL.md`

### Additional Discovery

- **Monorepo**: Skills in nested `.claude/skills/` directories are auto-discovered (e.g., `packages/frontend/.claude/skills/`)
- **`--add-dir`**: Skills from additional directories support **live change detection** — you can edit them during a session without restarting
- **`--add-dir` CLAUDE.md**: CLAUDE.md files from additional directories require `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` to be loaded

---

## Skills vs Commands vs Agents

| Feature | Skills (`.claude/skills/`) | Commands (`.claude/commands/`) | Agents (`.claude/agents/`) |
|---------|---------------------------|-------------------------------|---------------------------|
| Status | **Current** | `[legacy]` backward-compatible | Separate system |
| Entry file | `SKILL.md` | `<name>.md` | `<name>.md` |
| Supporting files | Yes (same directory) | No | No |
| Frontmatter control | Full (all fields) | Full (same fields) | Separate frontmatter |
| Auto-invocation | Yes (via description) | Yes | N/A (delegated by Claude) |
| Name conflict | Skills take precedence | — | Different namespace |

**Migration**: If you have `.claude/commands/deploy.md`, creating `.claude/skills/deploy/SKILL.md` will supersede it. The old command file continues to work until you remove it.

### Compatibility Note

`allowed-tools` is a **Claude Code CLI feature**. When using the Agent SDK or API directly, tool permissions are configured differently (via the SDK's tool configuration). Skills authored for Claude Code CLI may need adaptation for other runtimes.

---

## Hooks in Skills

Skills can define lifecycle hooks in frontmatter. These hooks are **scoped to the skill's duration** and automatically cleaned up when the skill finishes.

### Common Events

All Claude Code hook events are supported in skill frontmatter. The most commonly used are:

| Event | When | Use Case |
|-------|------|----------|
| `PreToolUse` | Before a tool is called | Validation, security checks, blocking unsafe operations |
| `PostToolUse` | After a tool completes | Logging, cleanup, notifications |
| `Stop` | When the skill/agent stops | Final cleanup, reporting |

> See the [Claude Code Hooks Documentation](https://code.claude.com/docs/en/hooks) for the full list of supported events.

### Hook Format

```yaml
hooks:
  PreToolUse:
    - matcher: Bash          # Tool name to intercept
      hooks:
        - type: command
          command: "./scripts/check.sh"
          once: true          # Skills-only: run once per session then remove
```

### The `once` Field

The `once: true` flag is a **skills-only feature** (not available in agent hooks or settings hooks). When set, the hook runs exactly once per session and then self-removes. Useful for one-time setup or validation.

---

## Description Writing Guide

| Rule | Good | Bad |
|------|------|-----|
| Third person | "Generates unit tests for..." | "I can generate tests..." |
| Max 1024 chars | Keep it concise | Long essays |
| No XML tags | Plain text only | `<tool>Generate</tool>` |
| Single line YAML | `description: Generates tests` | `description: >-` (may not parse correctly) |
| Specific | "Generates pytest tests for Python files" | "Does testing stuff" |

---

## Variables and Dynamic Context

### Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `$ARGUMENTS` | All arguments as a single string | `/review src/main.ts --verbose` → `src/main.ts --verbose` |
| `$ARGUMENTS[N]` | Specific argument by 0-based index | `$ARGUMENTS[0]` → `src/main.ts` |
| `$N` | Shorthand for `$ARGUMENTS[N]` | `$0` → `src/main.ts`, `$1` → `--verbose` |
| `${CLAUDE_SESSION_ID}` | Current session ID | For logging and correlation |
| `${CLAUDE_SKILL_DIR}` | Directory containing this SKILL.md | For referencing supporting files and scripts |

### Dynamic Context Injection

The `` !`command` `` syntax runs shell commands **before** the skill content is sent to Claude. The output replaces the placeholder. This is preprocessing — Claude only sees the result.

```markdown
## Current Branch
!`git branch --show-current`

## Changed Files
!`git diff --name-only main...HEAD`
```

### Extended Thinking

Including the word **"ultrathink"** anywhere in skill content enables extended thinking mode for that invocation.

---

## `allowed-tools` Reference

### Common Tools

| Tool | Description |
|------|-------------|
| `Read` | Read file contents |
| `Write` | Create or overwrite files |
| `Edit` | Edit existing files (find and replace) |
| `Glob` | Find files by pattern |
| `Grep` | Search file contents |
| `Bash(*)` | Any shell command |
| `Agent` | Spawn subagents |

### Wildcard Patterns

| Pattern | Matches |
|---------|---------|
| `Bash(git *)` | `git status`, `git diff`, `git log`, etc. |
| `Bash(npm:*)` | `npm install`, `npm test`, etc. |
| `mcp__server-name__*` | All tools from an MCP server |

### Least Privilege Principle

Only grant the tools the skill actually needs. Prefer specific patterns over `Bash(*)`:

```yaml
# Too broad
allowed-tools: Bash(*)

# Better
allowed-tools: Read, Grep, Bash(git diff *), Bash(git log *)
```

---

## Validation and Troubleshooting

### Validating Skills

```bash
# Validate against Agent Skills standard
skills-ref validate ./my-skill

# Check YAML frontmatter parsing
cat .claude/skills/my-skill/SKILL.md | head -20

# Verify skill is loaded
claude --debug  # Look for skill loading messages

# Check description budget
/context  # Shows if skills are excluded due to budget overflow
```

### Common Mistakes

| Mistake | Fix |
|---------|-----|
| YAML indentation error | Use 2 spaces, no tabs |
| Field name typo (`allowed_tools`) | Use hyphens: `allowed-tools` |
| Missing `description` | Add one — without it, Claude can't auto-discover |
| YAML multiline (`>-`, `\|`) in description | Keep description on a single line |
| Directory name doesn't match `name` | Ensure they're identical |
| Editing skill during session | Restart Claude Code (except `--add-dir` skills) |
| `context: fork` without task instructions | Fork runs in isolation — skill must contain a complete task, not just guidelines |

---

## Security

### Third-Party Skills

Treat third-party skills like software you install:

- **Audit scripts**: Check `scripts/` for anything unexpected before using
- **Review `!` commands**: Dynamic context injection runs shell commands — verify they're safe
- **Check `allowed-tools`**: Understand what tools the skill can use without confirmation
- **Review hooks**: `PreToolUse` and `PostToolUse` hooks execute shell commands automatically

### Least Privilege

- Grant only the tools the skill actually needs in `allowed-tools`
- Prefer specific Bash patterns (`Bash(git *)`) over `Bash(*)`
- Use `disable-model-invocation: true` for skills with side effects

---

## FAQ

**Q: Can I have multiple SKILL.md files in one directory?**
A: No. Each skill directory has exactly one `SKILL.md` file.

**Q: What happens if a skill and a command have the same name?**
A: The skill takes precedence. The command still works if you remove the skill.

**Q: Can Claude invoke a skill from inside another skill?**
A: Yes, if the inner skill's `disable-model-invocation` is not `true`.

**Q: Do supporting files count against the description budget?**
A: No. Only `name` and `description` are loaded at startup. Supporting files are accessed on-demand when the skill is invoked.

**Q: Can I use SKILL.md without frontmatter?**
A: Claude Code will accept it (inferring `name` from the directory and `description` from the first paragraph), but it will not be Agent Skills spec-compliant. Always include `name` and `description` for portability.

**Q: What's the recommended max length for SKILL.md?**
A: Keep it under **500 lines**. Move detailed references, checklists, and rules to separate files in the same directory.
