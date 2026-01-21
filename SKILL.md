---
name: agent-skills
description: Development standards, workflows, and AI agent configurations for TypeScript, Astro, and modern web development
---

# Agent Skills Package

A comprehensive collection of coding standards, reusable prompts, and specialized AI agents for consistent, high-quality software development.

## What This Package Provides

### Instructions (Guardrails)
Coding standards that apply automatically based on file patterns:
- **TypeScript** - Strict type safety, no `any`, explicit returns
- **Astro** - Component patterns, Tailwind usage, accessibility
- **JSON Schema** - Draft-04 compatibility, `$ref` patterns
- **Git** - Commit message format, PR guidelines, branch naming
- **Security** - No secrets in code, input validation, dependency checks

### Prompts (Workflows)
Reusable commands for common development tasks:
- `/code-review` - Systematic review for bugs, security, and performance
- `/pr-description` - Generate PR descriptions from changes
- `/debug-issue` - Structured debugging workflow
- `/refactor` - Safe refactoring with test preservation
- `/test-plan` - Generate comprehensive test cases

### Agents (Personas)
Specialized AI assistants for focused tasks:
- **Code Reviewer** - Quality-focused code analysis
- **Architect** - System design and patterns advisor
- **Test Engineer** - Testing strategy specialist

## When to Use This Package

Install this package when you want to:
- Apply consistent coding standards across projects
- Have reliable, repeatable workflows for common tasks
- Use specialized AI agents for focused work
- Share development best practices with your team

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
```

## Package Structure

```
.apm/
├── instructions/     # Coding standards (auto-applied by file pattern)
├── prompts/          # Reusable workflow commands
└── agents/           # Specialized AI personas
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
| `@architect` | AWS MCP, Context7 | Infrastructure patterns, library docs |
| `@test-engineer` | (uses agent-browser) | Browser automation for E2E testing |

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

### Skills vs MCP Strategy

This package follows a **Skills-first** approach:
- **APM Skills** (like `vercel-labs/agent-browser`) are declared as dependencies
- **MCP Servers** are documented but not declared, letting consumers choose

This keeps the package lightweight while providing guidance for enhanced capabilities.
