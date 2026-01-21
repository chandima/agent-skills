# Agent Skills

[![Install with APM](https://img.shields.io/badge/%F0%9F%93%A6_Install_with-APM-blue?style=flat-square)](https://github.com/danielmeppiel/apm)

Development standards, workflows, and AI agent configurations for consistent, high-quality software development.

> **New to APM?** Start with the [Getting Started Tutorial](docs/GETTING_STARTED.md) to build a todo app with OpenCode.
>
> **Want to understand the architecture?** See [docs/FRAMEWORK.md](docs/FRAMEWORK.md) for how primitives work together.

## Architecture

This package uses a **lightweight agents + modular skills** architecture:

```
┌─────────────────────────────────────────────────────────────┐
│  Agents (Personas)           Skills (Expertise)             │
│  ─────────────────           ─────────────────              │
│  @code-reviewer       →      review/code, review/security   │
│  @architect           →      architecture/patterns          │
│  @test-engineer       →      testing/strategy, testing/e2e  │
│  @devops-engineer     →      devops/cicd, devops/iac, ...   │
│  @fullstack-developer →      stack/sst, stack/astro, ...    │
└─────────────────────────────────────────────────────────────┘
```

- **Agents** are lightweight personas (~80-100 lines) with tool permissions
- **Skills** are reusable expertise modules loaded dynamically
- **Context bloat reduced by ~37%** compared to monolithic agents

## Installation

### Install APM

**macOS (Homebrew)**
```bash
brew install danielmeppiel/tap/apm
```

**Other platforms**
```bash
curl -sSL https://raw.githubusercontent.com/danielmeppiel/apm/main/install.sh | sh
```

### Install this package

```bash
# Install the skills package
apm install chandima/agent-skills

# Compile for your AI tools
apm compile
```

### Compile for Specific AI Tools

APM compiles skills into the format each AI tool expects:

| Target | Output Files | Best For |
|--------|--------------|----------|
| `vscode` | `AGENTS.md`, `.github/prompts/`, `.github/agents/`, `.github/skills/` | GitHub Copilot, Cursor, Codex, Gemini |
| `claude` | `CLAUDE.md`, `.claude/commands/`, `SKILL.md` | Claude Code, Claude Desktop |
| `all` | All of the above | Universal compatibility |

**Auto-detection behavior:**
- `.github/` exists only → compiles for `vscode` target
- `.claude/` exists only → compiles for `claude` target
- Both folders exist → compiles for `all` targets
- Neither exists → `minimal` mode (AGENTS.md only)

```bash
# Auto-detect and compile (recommended)
apm compile

# Or specify targets explicitly
apm compile --target vscode
apm compile --target claude
apm compile --target all
```

## What's Included

### Skills (Expertise Modules)

Fine-grained knowledge packages loaded by agents. Skills focus on **detection methodology** (how to find issues) rather than coding patterns (which belong in instructions):

| Domain | Skills | Purpose |
|--------|--------|---------|
| **review/** | `code`, `security` | Review methodology, vulnerability detection |
| **testing/** | `strategy`, `e2e` | Testing pyramid, Playwright/agent-browser |
| **devops/** | `cicd`, `containers`, `iac`, `security` | Pipeline audit, Dockerfile review, IaC review |
| **architecture/** | `patterns` | System design, trade-off analysis |
| **stack/** | `sst`, `astro`, `alpine`, `basecoat` | Full-stack technology expertise |

### Agents (AI Personas)

| Agent | Skills | Focus |
|-------|--------|-------|
| `@code-reviewer` | review/code, review/security | Code quality (read-only) |
| `@architect` | architecture/patterns, review/code | System design |
| `@test-engineer` | testing/strategy, testing/e2e | Test coverage |
| `@devops-engineer` | devops/cicd, containers, iac, security | CI/CD, infrastructure |
| `@fullstack-developer` | stack/sst, astro, alpine, basecoat | SST + Astro stack |

### Instructions (Coding Standards)

Auto-applied guardrails that define **how to write code** (vs. skills which define how to review code):

| File | Applies To | Purpose |
|------|------------|---------|
| `typescript.instructions.md` | `**/*.{ts,tsx}` | Strict types, no `any` |
| `astro.instructions.md` | `**/*.astro` | Basecoat UI, Islands |
| `alpinejs.instructions.md` | `**/*.{astro,html}` | Directives, state |
| `sst.instructions.md` | `**/sst.config.ts` | AWS components |
| `github-actions.instructions.md` | `.github/workflows/**` | OIDC, permissions |
| `terraform.instructions.md` | `**/*.tf` | HCL patterns, modules |
| `docker.instructions.md` | `**/Dockerfile*` | Multi-stage, security |
| `jenkins.instructions.md` | `**/Jenkinsfile*` | Declarative pipelines |
| `git.instructions.md` | All files | Conventional commits |
| `security.instructions.md` | All code | No secrets, validation |
| `json-schema.instructions.md` | `**/*.schema.json` | Draft-04, `$ref` |

### Prompts (Workflows)

| Command | Purpose |
|---------|---------|
| `/code-review` | Systematic review for bugs, security, performance |
| `/pr-description` | Generate PR description from staged changes |
| `/debug-issue` | Structured debugging workflow |
| `/refactor` | Safe refactoring with test preservation |
| `/test-plan` | Generate comprehensive test cases |

## Usage Examples

### Using Agents

```
@code-reviewer Please review the changes in src/auth/
@architect How should I structure a caching layer for this API?
@test-engineer What test cases should I write for the payment flow?
@devops-engineer Set up a CI/CD pipeline for this Node.js project
@fullstack-developer Build a file upload feature with S3 and progress indicator
```

### Using Prompts

```bash
/code-review
/pr-description
/debug-issue --param error="TypeError: undefined is not a function"
```

## Package Structure

```
.apm/
├── instructions/     # Coding standards (11 files)
├── prompts/          # Workflow commands (5 files)
├── agents/           # Lightweight personas (5 files, ~80-100 lines each)
└── skills/           # Expertise modules (13 skills)
    ├── review/       # code, security
    ├── testing/      # strategy, e2e
    ├── devops/       # cicd, containers, iac, security
    ├── architecture/ # patterns
    └── stack/        # sst, astro, alpine, basecoat
```

## Installing Individual Components

```bash
# Install just the code-review prompt
apm install chandima/agent-skills/.apm/prompts/code-review.prompt.md

# Install just the architect agent
apm install chandima/agent-skills/.apm/agents/architect.agent.md

# Install just the TypeScript standards
apm install chandima/agent-skills/.apm/instructions/typescript.instructions.md

# Install a specific skill
apm install chandima/agent-skills/.apm/skills/devops/cicd/SKILL.md
```

## Dependencies

This package includes:
- `vercel-labs/agent-browser` - Browser automation CLI for E2E testing
- `vercel-labs/agent-skills#web-design-guidelines` - 100+ UI/UX/accessibility audit rules

### Optional Dependencies

```bash
# n8n workflow automation (requires n8n-mcp MCP server)
apm install czlonkowski/n8n-skills
```

## MCP Server Compatibility

This package works alongside MCP servers for enhanced capabilities:

| Server | Use Case | Benefits |
|--------|----------|----------|
| **GitHub MCP** | Code review, PR workflows | PR context, code search |
| **Terraform MCP** | Infrastructure | State inspection, plan interpretation |
| **Context7** | Library documentation | Up-to-date framework docs |
| **n8n-mcp** | Workflow automation | Node docs, validation |

### GitHub Enterprise Cloud (ghe.com)

```json
{
  "github": {
    "type": "http", 
    "url": "https://copilot-api.<your-subdomain>.ghe.com/mcp"
  }
}
```

## Customization

After installing, customize any file in your project's `.apm/` directory. Local changes take precedence over package defaults.

## Primitive Architecture

This package follows the [AI-Native Development framework](docs/FRAMEWORK.md). Key distinction:

| Primitive | Purpose | Content Type |
|-----------|---------|--------------|
| **Instructions** | HOW TO WRITE code | Coding rules, patterns, examples |
| **Skills** | HOW TO FIND issues | Detection methodology, grep patterns |
| **Prompts** | Workflow execution | Orchestration steps |
| **Agents** | AI personas | Identity, tool permissions, skill refs |

For a complete explanation, see [docs/FRAMEWORK.md](docs/FRAMEWORK.md).

## Contributing

Found an issue or have a suggestion? Open an issue or PR on [GitHub](https://github.com/chandima/agent-skills).

## License

MIT
