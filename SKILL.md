---
name: agent-skills
description: Development standards, workflows, and AI agent configurations for SST, Astro, Alpine.js, and modern full-stack development. Use when setting up coding standards, running code reviews, creating PRs, debugging issues, or planning tests.
metadata:
  author: chandima
  version: "1.1.0"
---

# Agent Skills Package

A comprehensive collection of coding standards, reusable prompts, and specialized AI agents for consistent, high-quality software development.

## How It Works

1. Install the package with `apm install chandima/agent-skills`
2. Compile for your AI tool with `apm compile --target <tool>`
3. Instructions are applied automatically based on file patterns
4. Prompts are available as `/commands`
5. Agents are available as `@mentions`

## What This Package Provides

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

### Agents (Personas)
Specialized AI assistants for focused tasks:

| Agent | Mention | Specialty |
|-------|---------|-----------|
| Code Reviewer | `@code-reviewer` | Quality-focused code analysis (read-only) |
| Architect | `@architect` | System design and patterns advisor |
| Test Engineer | `@test-engineer` | Testing strategy, Playwright, coverage |
| DevOps Engineer | `@devops-engineer` | CI/CD pipelines, IaC, containerization |
| Full-Stack Developer | `@fullstack-developer` | SST, Astro, Alpine.js, Basecoat UI stack |

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
| [Web Interface Guidelines](https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md) | External | Source for web-design-guidelines rules |
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

This package works best when combined with MCP servers for enhanced context. The following recommendations help AI agents select appropriate tools:

### By Prompt Type

| Prompt | Recommended MCP | Benefit |
|--------|-----------------|---------|
| `/code-review` | GitHub MCP | Access PR context, comments, review history |
| `/pr-description` | GitHub MCP | Read issue details, linked PRs, commit history |
| `/test-plan` | (none needed) | Uses `vercel-labs/agent-browser` APM skill |
| `/debug-issue` | Context7 | Up-to-date library documentation |
| `/refactor` | Context7 | Current API patterns and best practices |

### By Agent Type

| Agent | Recommended MCP | Benefit |
|-------|-----------------|---------|
| `@code-reviewer` | GitHub MCP | Repository context, PR details |
| `@architect` | AWS MCP, Context7, n8n-mcp | Infrastructure patterns, library docs, workflow automation |
| `@test-engineer` | (uses agent-browser) | Browser automation for E2E testing |
| `@devops-engineer` | GitHub MCP, Terraform MCP | CI/CD context, infrastructure state |
| `@fullstack-developer` | Context7, SST Console | Library docs, deployment monitoring |

### n8n Workflow Automation

For building n8n workflows programmatically, use **n8n-mcp** with **n8n-skills**:

```bash
# Install n8n-mcp MCP server
npx n8n-mcp

# Install n8n skills (optional, for Claude Code)
apm install czlonkowski/n8n-skills
```

**n8n-mcp** provides:
- 1,084 n8n nodes (537 core + 547 community)
- Node property schemas and validation
- 2,709 workflow templates
- Workflow create/update/execute via n8n API

**n8n-skills** provides 7 complementary skills:
| Skill | Purpose |
|-------|---------|
| n8n Expression Syntax | Correct `{{}}` patterns, `$json`/`$node` variables |
| n8n MCP Tools Expert | Effective use of n8n-mcp tools |
| n8n Workflow Patterns | 5 proven architectural patterns |
| n8n Validation Expert | Error interpretation and fixing |
| n8n Node Configuration | Operation-aware node setup |
| n8n Code JavaScript | Code node patterns and gotchas |
| n8n Code Python | Python limitations and workarounds |

**Configuration** (Claude Desktop):
```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["n8n-mcp"],
      "env": {
        "MCP_MODE": "stdio",
        "N8N_API_URL": "https://your-n8n-instance.com",
        "N8N_API_KEY": "your-api-key"
      }
    }
  }
}
```

### For GitHub Enterprise Cloud (ghe.com)

Organizations using GHEC with data residency should configure GitHub MCP with:

```json
{
  "url": "https://copilot-api.<subdomain>.ghe.com/mcp"
}
```

This enables code search across organization repositories using:
- `search_code` with `org:YourOrg` filter
- `search_repositories` for repo discovery
- `list_pull_requests` for tracking work

### Terraform MCP

For Terraform/OpenTofu workflows, the Terraform MCP server provides:
- Provider and resource documentation lookup
- State file inspection and drift detection
- Module registry search
- Plan output interpretation

```json
{
  "terraform-mcp": {
    "command": "npx",
    "args": ["terraform-mcp-server"],
    "env": {
      "TERRAFORM_BINARY": "terraform"
    }
  }
}
```

Use with the `@devops-engineer` agent for infrastructure automation tasks.

### Skills vs MCP Strategy

This package follows a **Skills-first** approach:
- **APM Skills** (like `vercel-labs/agent-browser`) are declared as dependencies
- **MCP Servers** are documented but not declared, letting consumers choose

This keeps the package lightweight while providing guidance for enhanced capabilities.

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
└── agents/           # Specialized AI personas
    ├── code-reviewer.agent.md
    ├── architect.agent.md
    ├── test-engineer.agent.md
    ├── devops-engineer.agent.md
    └── fullstack-developer.agent.md
```

## Quick Start

```bash
# Install in any project
apm install chandima/agent-skills
apm compile

# Use prompts
/code-review
/pr-description

# Use agents via @ mention
@code-reviewer review the authentication module
@architect design a caching layer
@test-engineer write E2E tests for checkout flow
@fullstack-developer set up a file upload feature with SST and Alpine.js
```

## When to Use This Package

Install this package when you want to:
- Apply consistent coding standards across projects
- Have reliable, repeatable workflows for common tasks
- Use specialized AI agents for focused work
- Share development best practices with your team
- Audit UI code for accessibility and UX compliance
