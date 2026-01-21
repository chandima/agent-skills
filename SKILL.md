---
name: agent-skills
description: Development standards, workflows, and AI agent configurations for SST, Astro, Alpine.js, and modern full-stack development. Use when setting up coding standards, running code reviews, creating PRs, debugging issues, or planning tests.
metadata:
  author: chandima
  version: "2.0.0"
---

# Agent Skills Package

A comprehensive collection of coding standards, reusable prompts, specialized AI agents, and fine-grained skills for consistent, high-quality software development.

## Architecture: Agents + Skills

This package uses a **lightweight agents + modular skills** architecture:

- **Agents** define personas, tool permissions, and responsibilities (~80-100 lines each)
- **Skills** provide reusable expertise modules loaded dynamically by agents
- **Instructions** apply coding standards automatically based on file patterns
- **Prompts** provide workflow commands for common development tasks

This architecture reduces context bloat by ~37% compared to monolithic agents while enabling expertise reuse across different agent types.

## How It Works

1. Install the package with `apm install chandima/agent-skills`
2. Compile for your AI tool with `apm compile --target <tool>`
3. Instructions are applied automatically based on file patterns
4. Prompts are available as `/commands`
5. Agents are available as `@mentions` and load their skills dynamically

## What This Package Provides

### Skills (Expertise Modules)

Fine-grained knowledge packages loaded dynamically by agents:

| Domain | Skills | Description |
|--------|--------|-------------|
| **review/** | `code`, `security` | Code quality patterns, security vulnerability detection |
| **testing/** | `strategy`, `e2e` | Testing pyramid, patterns, Playwright/agent-browser |
| **devops/** | `cicd`, `containers`, `iac`, `security` | CI/CD, Docker, Terraform, DevSecOps |
| **architecture/** | `patterns` | System design, trade-off analysis, anti-patterns |
| **stack/** | `sst`, `astro`, `alpine`, `basecoat` | Full-stack technology expertise |

### Agents (Personas)

Lightweight AI assistants that load relevant skills:

| Agent | Skills Loaded | Specialty |
|-------|---------------|-----------|
| `@code-reviewer` | review/code, review/security | Quality-focused code analysis (read-only) |
| `@architect` | architecture/patterns, review/code | System design and patterns advisor |
| `@test-engineer` | testing/strategy, testing/e2e, review/code | Testing strategy, Playwright, coverage |
| `@devops-engineer` | devops/cicd, devops/containers, devops/iac, devops/security | CI/CD, IaC, containerization |
| `@fullstack-developer` | stack/sst, stack/astro, stack/alpine, stack/basecoat, testing/e2e | SST, Astro, Alpine.js, Basecoat UI |

### Instructions (Guardrails)

Coding standards that apply automatically based on file patterns:

| Instruction | File Pattern | Key Rules |
|-------------|--------------|-----------|
| TypeScript | `**/*.{ts,tsx}` | Strict types, no `any`, explicit returns |
| Astro | `**/*.astro` | Basecoat UI, Alpine.js, Islands architecture |
| Alpine.js | `**/*.{astro,html}` | Directives, magics, plugins, state patterns |
| SST | `**/sst.config.ts` | AWS components, linking, Pulumi integration |
| JSON Schema | `**/*.schema.json` | Draft-04 compatibility, `$ref` patterns |
| Git | All files | Conventional commits, PR guidelines |
| Security | All code | No secrets, input validation, dependency checks |
| GitHub Actions | `.github/workflows/**/*.{yml,yaml}` | OIDC, permissions, reusable workflows |
| Terraform | `**/*.tf` | HCL patterns, modules, state management |
| Jenkins | `**/Jenkinsfile*` | Declarative pipelines, shared libraries |
| Docker | `**/Dockerfile*` | Multi-stage builds, security, layer optimization |

### Prompts (Workflows)

Reusable commands for common development tasks:

| Prompt | Command | Use When |
|--------|---------|----------|
| Code Review | `/code-review` | Reviewing code for bugs, security, performance |
| PR Description | `/pr-description` | Generating PR descriptions from changes |
| Debug Issue | `/debug-issue` | Structured debugging workflow |
| Refactor | `/refactor` | Safe refactoring with test preservation |
| Test Plan | `/test-plan` | Generating comprehensive test cases |

## Package Structure

```
.apm/
├── instructions/     # Coding standards (auto-applied by file pattern)
│   ├── typescript.instructions.md
│   ├── astro.instructions.md
│   ├── alpinejs.instructions.md
│   ├── sst.instructions.md
│   ├── json-schema.instructions.md
│   ├── git.instructions.md
│   ├── security.instructions.md
│   ├── github-actions.instructions.md
│   ├── terraform.instructions.md
│   ├── jenkins.instructions.md
│   └── docker.instructions.md
├── prompts/          # Reusable workflow commands
│   ├── code-review.prompt.md
│   ├── pr-description.prompt.md
│   ├── debug-issue.prompt.md
│   ├── refactor.prompt.md
│   └── test-plan.prompt.md
├── agents/           # Lightweight AI personas (~80-100 lines each)
│   ├── code-reviewer.agent.md
│   ├── architect.agent.md
│   ├── test-engineer.agent.md
│   ├── devops-engineer.agent.md
│   └── fullstack-developer.agent.md
└── skills/           # Fine-grained expertise modules
    ├── review/
    │   ├── code/SKILL.md
    │   └── security/SKILL.md
    ├── testing/
    │   ├── strategy/SKILL.md
    │   └── e2e/SKILL.md
    ├── devops/
    │   ├── cicd/SKILL.md
    │   ├── containers/SKILL.md
    │   ├── iac/SKILL.md
    │   └── security/SKILL.md
    ├── architecture/
    │   └── patterns/SKILL.md
    └── stack/
        ├── sst/SKILL.md
        ├── astro/SKILL.md
        ├── alpine/SKILL.md
        └── basecoat/SKILL.md
```

## Quick Start

```bash
# Install in any project
apm install chandima/agent-skills
apm compile

# Use prompts
/code-review
/pr-description

# Use agents via @ mention (they load skills automatically)
@code-reviewer review the authentication module
@architect design a caching layer
@test-engineer write E2E tests for checkout flow
@fullstack-developer set up a file upload feature with SST and Alpine.js
```

## Scripts

Prompts can be invoked directly as commands:

```bash
# Run a code review on the current changes
/code-review

# Generate a PR description
/pr-description

# Debug an issue with structured workflow
/debug-issue "Error: Connection timeout"

# Plan refactoring with safety checks
/refactor src/api/

# Generate test plan for a feature
/test-plan user-authentication
```

## References

This package integrates with and references:

| Resource | Type | Purpose |
|----------|------|---------|
| [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) | APM Skill | Browser automation for E2E testing |
| [agent-browser SKILL.md](https://github.com/vercel-labs/agent-browser/blob/main/skills/agent-browser/SKILL.md) | Skill Reference | Full command reference for agent-browser |
| [vercel-labs/agent-skills#web-design-guidelines](https://github.com/vercel-labs/agent-skills) | APM Skill | 100+ UI/UX/accessibility audit rules |
| [czlonkowski/n8n-skills](https://github.com/czlonkowski/n8n-skills) | Optional Skill | 7 skills for n8n workflow automation |
| [czlonkowski/n8n-mcp](https://github.com/czlonkowski/n8n-mcp) | MCP Server | n8n node docs, validation, workflow management |
| [Agent Skills Spec](https://agentskills.io/) | Specification | SKILL.md format documentation |

## Dependencies

This package declares the following APM dependencies:

```yaml
dependencies:
  apm:
    - vercel-labs/agent-browser          # Browser automation
    - vercel-labs/agent-skills#web-design-guidelines  # UI/UX audit
```

## MCP Server Recommendations

This package works best when combined with MCP servers for enhanced context:

### By Agent Type

| Agent | Recommended MCP | Benefit |
|-------|-----------------|---------|
| `@code-reviewer` | GitHub MCP | Repository context, PR details |
| `@architect` | AWS MCP, Context7 | Infrastructure patterns, library docs |
| `@test-engineer` | (uses agent-browser) | Browser automation for E2E testing |
| `@devops-engineer` | GitHub MCP, Terraform MCP | CI/CD context, infrastructure state |
| `@fullstack-developer` | Context7, SST Console | Library docs, deployment monitoring |

### Skills vs MCP Strategy

This package follows a **Skills-first** approach:
- **APM Skills** (like `vercel-labs/agent-browser`) are declared as dependencies
- **MCP Servers** are documented but not declared, letting consumers choose

This keeps the package lightweight while providing guidance for enhanced capabilities.

## When to Use This Package

Install this package when you want to:
- Apply consistent coding standards across projects
- Have reliable, repeatable workflows for common tasks
- Use specialized AI agents for focused work
- Share development best practices with your team
- Audit UI code for accessibility and UX compliance
