# Agent Skills Repository

This repository hosts custom skills for AI coding agents and is intended to be installed via `npx skills add <owner>/<repo>`.

**This is not application code.** It contains skill definitions, scaffolding scripts, and templates.

## Repository Structure

```
skills/
  <skill-name>/
    SKILL.md            # Skill definition (required)
    README.md           # Local usage notes (optional)
    scripts/            # Helper scripts (optional)
    assets/             # Templates/data (optional)
    references/         # Supporting docs (optional)
    tests/              # Smoke tests (optional)
```

## Skill Conventions

### Naming
- Skill directory: `kebab-case`
- Required file: `SKILL.md` (uppercase)
- Scripts: `scripts/*.sh` (bash preferred)

### SKILL.md Frontmatter

```yaml
---
name: skill-name
description: "Concise description with trigger phrases"
allowed-tools: Read, Write, Bash(./scripts/*)
---
```

## Workflow Notes

- Use available skills when relevant to the task. If a skill exists that matches the request, invoke it instead of re-implementing its logic.
- Keep templates aligned with upstream or official references when applicable.
- Do not add an upstream git remote unless explicitly requested.

## Testing

- If you modify scripts, run the skill smoke tests:
  - `bash scripts/run-skill-tests.sh`
