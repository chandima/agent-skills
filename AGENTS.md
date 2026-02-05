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

- Skill usage is mandatory when a relevant skill exists. Do not proceed with manual logic if a matching skill is available.
- Always scan the available skills list and explicitly invoke the applicable skill(s) before doing any work.
- If multiple skills apply, pick the minimal set that covers the request and use them in a clear order.
- If you decide not to use an obvious skill, explicitly state why.
- After invoking a skill, follow its `SKILL.md` workflow (scripts/templates/references) rather than re-implementing.
- Keep templates aligned with upstream or official references when applicable.
- Do not add an upstream git remote unless explicitly requested.

## Testing

- If you modify scripts, run the skill smoke tests:
  - `bash scripts/run-skill-tests.sh`
