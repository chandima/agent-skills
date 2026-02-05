# Agent Skills (Custom)

This repository hosts a minimal set of skills for AI coding agents.

## Upstream

This repository is standalone and does not track an upstream source.

## Available Skills

- `h5p-type-scaffold` — scaffold a modern H5P content type (library) from curated boilerplates (default: SNORDIAN).

## Install with `skills`

```bash
# Install all skills
npx skills add chandima/agent-skills --all

# Install a specific skill
npx skills add chandima/agent-skills --skill h5p-type-scaffold

# Install all skills to specific agents
npx skills add chandima/agent-skills --skill '*' -a claude-code -a opencode -a codex

# Install specific skills to all agents
npx skills add chandima/agent-skills --agent '*' --skill h5p-type-scaffold

# Install a specific skill to a specific agent
npx skills add chandima/agent-skills --skill h5p-type-scaffold -a codex

# List available skills in the repo
npx skills add chandima/agent-skills --list
```

### Install Options

| Option                    | Description                                                         |
| ------------------------- | ------------------------------------------------------------------- |
| `-g, --global`            | Install to user directory instead of project                        |
| `-a, --agent <agents...>` | Target specific agents (e.g., `claude-code`, `codex`)               |
| `-s, --skill <skills...>` | Install specific skills by name (use `'*'` for all skills)          |
| `-l, --list`              | List available skills without installing                            |
| `-y, --yes`               | Skip all confirmation prompts                                       |
| `--all`                   | Install all skills to all agents without prompts                    |

## Testing

Run all skill smoke tests:

```bash
bash scripts/run-skill-tests.sh
```

CI runs the same script on every PR and push to `main` via `.github/workflows/skill-tests.yml`.
