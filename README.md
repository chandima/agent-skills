# Agent Skills

[![Install with APM](https://img.shields.io/badge/%F0%9F%93%A6_Install_with-APM-blue?style=flat-square)](https://github.com/danielmeppiel/apm)

Development standards, workflows, and AI agent configurations for consistent, high-quality software development.

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

APM compiles skills into the format each AI tool expects. Use the `--target` flag to compile for specific tools:

**Claude Code**
```bash
apm compile --target claude-code
# Output: CLAUDE.md in your project root
```

**OpenAI Codex / ChatGPT**
```bash
apm compile --target codex
# Output: .codex/instructions.md
```

**OpenCode**
```bash
apm compile --target opencode
# Output: .opencode/instructions.md
```

**All supported targets**
```bash
# Compile for all detected AI tools at once
apm compile

# Or specify multiple targets
apm compile --target claude-code --target opencode --target codex
```

**Available compile targets:**
| Target | Output Location | AI Tool |
|--------|-----------------|---------|
| `claude-code` | `CLAUDE.md` | Claude Code (Anthropic) |
| `codex` | `.codex/instructions.md` | OpenAI Codex / ChatGPT |
| `opencode` | `.opencode/instructions.md` | OpenCode CLI |
| `cursor` | `.cursor/rules/` | Cursor IDE |
| `windsurf` | `.windsurf/rules/` | Windsurf IDE |
| `cline` | `.clinerules/` | Cline Extension |

> **Tip**: Run `apm compile` without flags to auto-detect installed AI tools and compile for all of them.

## Installing Individual Components

You can install the full package or pick individual agents, prompts, and instructions.

### Install the Full Package

```bash
# Installs all instructions, prompts, agents, and dependencies
apm install chandima/agent-skills
```

### Install Individual Files (Virtual Packages)

APM supports installing single files directly from any repository:

```bash
# Install just the code-review prompt
apm install chandima/agent-skills/.apm/prompts/code-review.prompt.md

# Install just the architect agent
apm install chandima/agent-skills/.apm/agents/architect.agent.md

# Install just the TypeScript standards
apm install chandima/agent-skills/.apm/instructions/typescript.instructions.md
```

### Available Components

**Prompts** (install individually with `/.apm/prompts/<name>.prompt.md`):
| File | Command |
|------|---------|
| `code-review.prompt.md` | `/code-review` |
| `pr-description.prompt.md` | `/pr-description` |
| `debug-issue.prompt.md` | `/debug-issue` |
| `refactor.prompt.md` | `/refactor` |
| `test-plan.prompt.md` | `/test-plan` |

**Agents** (install individually with `/.apm/agents/<name>.agent.md`):
| File | Persona |
|------|---------|
| `code-reviewer.agent.md` | `@code-reviewer` |
| `architect.agent.md` | `@architect` |
| `test-engineer.agent.md` | `@test-engineer` |
| `devops-engineer.agent.md` | `@devops-engineer` |

**Instructions** (install individually with `/.apm/instructions/<name>.instructions.md`):
| File | Applies To |
|------|------------|
| `typescript.instructions.md` | `**/*.{ts,tsx}` |
| `astro.instructions.md` | `**/*.astro` |
| `json-schema.instructions.md` | `**/*.schema.json` |
| `git.instructions.md` | All files |
| `security.instructions.md` | All code files |
| `github-actions.instructions.md` | `.github/workflows/**/*.{yml,yaml}` |
| `terraform.instructions.md` | `**/*.tf` |
| `jenkins.instructions.md` | `**/Jenkinsfile*` |
| `docker.instructions.md` | `**/Dockerfile*` |

### Add as a Dependency in Your Package

If you're building your own APM package, add this package (or individual components) to your `apm.yml`:

```yaml
# apm.yml
name: my-project
dependencies:
  apm:
    # Full package
    - chandima/agent-skills
    
    # Or individual components
    - chandima/agent-skills/.apm/prompts/code-review.prompt.md
    - chandima/agent-skills/.apm/agents/architect.agent.md
```

Then run:
```bash
apm install  # Installs all dependencies from apm.yml
apm compile  # Generates context files for your AI tools
```

### Create Custom Skills

To create your own instructions, prompts, or agents:

```bash
# Initialize a new APM package
apm init my-skills && cd my-skills
```

This creates the standard structure:
```
my-skills/
├── apm.yml                          # Package manifest
├── SKILL.md                         # Package meta-guide
└── .apm/
    ├── instructions/                # Add .instructions.md files here
    ├── prompts/                     # Add .prompt.md files here
    └── agents/                      # Add .agent.md files here
```

**Example: Add a custom instruction**
```bash
cat > .apm/instructions/react.instructions.md << 'EOF'
---
applyTo: "**/*.{jsx,tsx}"
---
# React Standards
- Use functional components with hooks
- Prefer named exports over default exports
- Co-locate tests with components
EOF
```

**Example: Add a custom prompt**
```bash
cat > .apm/prompts/generate-tests.prompt.md << 'EOF'
---
description: "Generate unit tests for the selected code"
---
# Test Generator

Analyze the provided code and generate comprehensive unit tests.

## Output
- Use the project's existing test framework
- Include edge cases and error scenarios
- Follow AAA pattern (Arrange, Act, Assert)
EOF
```

Push to GitHub and anyone can install:
```bash
apm install your-username/my-skills
```

## What's Included

### Instructions (Coding Standards)

| File | Applies To | Purpose |
|------|------------|---------|
| `typescript.instructions.md` | `**/*.{ts,tsx}` | Strict types, no `any`, explicit returns |
| `astro.instructions.md` | `**/*.astro` | Component structure, Tailwind, accessibility |
| `json-schema.instructions.md` | `**/*.schema.json` | Draft-04 compatibility, `$ref` patterns |
| `git.instructions.md` | All files | Commit format, PR guidelines, branch naming |
| `security.instructions.md` | All code files | No secrets, input validation, dependency checks |
| `github-actions.instructions.md` | `.github/workflows/**/*.{yml,yaml}` | OIDC, permissions, reusable workflows, caching |
| `terraform.instructions.md` | `**/*.tf` | HCL patterns, modules, state management, CI/CD |
| `jenkins.instructions.md` | `**/Jenkinsfile*` | Declarative pipelines, shared libraries, credentials |
| `docker.instructions.md` | `**/Dockerfile*` | Multi-stage builds, security, layer optimization |

### Prompts (Workflows)

| Command | Purpose |
|---------|---------|
| `/code-review` | Systematic review for bugs, security, and performance |
| `/pr-description` | Generate PR description from staged changes |
| `/debug-issue` | Structured debugging workflow |
| `/refactor` | Safe refactoring with test preservation |
| `/test-plan` | Generate comprehensive test cases |

### Agents (AI Personas)

| Agent | Focus |
|-------|-------|
| `@code-reviewer` | Code quality, bugs, best practices |
| `@architect` | System design, patterns, scalability |
| `@test-engineer` | Test coverage, edge cases, reliability |
| `@devops-engineer` | CI/CD pipelines, infrastructure as code, containers |

## Usage Examples

### Using Prompts

```bash
# In your AI coding assistant
/code-review
/pr-description
/debug-issue --param error="TypeError: undefined is not a function"
```

### Using Agents

```
@code-reviewer Please review the changes in src/auth/
@architect How should I structure a caching layer for this API?
@test-engineer What test cases should I write for the payment flow?
@devops-engineer Set up a CI/CD pipeline for this Node.js project
```

## Customization

After installing, you can customize any file in your project's `.apm/` directory. Your local changes take precedence over the package defaults.

## Dependencies

This package includes:
- `vercel-labs/agent-browser` - Browser automation CLI for E2E testing ([full command reference](https://github.com/vercel-labs/agent-browser/blob/main/skills/agent-browser/SKILL.md))
- `vercel-labs/agent-skills#web-design-guidelines` - 100+ UI/UX/accessibility audit rules

### Optional Dependencies

Install separately if needed:

```bash
# n8n workflow automation (requires n8n-mcp MCP server)
apm install czlonkowski/n8n-skills
```

## MCP Server Compatibility

This skills package is designed to work alongside MCP (Model Context Protocol) servers for enhanced AI agent capabilities. Install these in your consuming project based on your workflow needs.

### Recommended MCP Servers

| Server | Use Case | Benefits |
|--------|----------|----------|
| **GitHub MCP** | Code review, PR workflows | PR context, issue tracking, code search across repos |
| **n8n-mcp** | Workflow automation | n8n node docs, validation, workflow management |
| **AWS MCP Servers** | Infrastructure code | CDK/CloudFormation guidance, security validation |
| **Context7** | Library documentation | Up-to-date docs for any framework/library |
| **Figma MCP** | Design-to-code | Design context for UI component implementation |

### GitHub Enterprise Cloud (ghe.com) Configuration

For organizations using GHEC with data residency (e.g., ASU's ~800 repos):

```json
{
  "github": {
    "type": "http", 
    "url": "https://copilot-api.<your-subdomain>.ghe.com/mcp",
    "headers": {
      "Authorization": "Bearer ${input:github_mcp_pat}"
    }
  }
}
```

### Searching Organization Repositories

The GitHub MCP server provides code search across repositories:
- Use `search_code` tool with org filter: `org:YourOrg <query>`
- Use `search_repositories` for repo discovery
- Use `list_issues` and `list_pull_requests` for project tracking

> **Note**: GitHub's semantic code search is currently Copilot-native and provides instant indexing. For MCP-based search, use keyword queries with good specificity. GitHub is working on exposing semantic search via API.

### AWS MCP Servers

For infrastructure-as-code workflows, AWS provides official MCP servers:

```json
{
  "aws-iac": {
    "command": "uvx",
    "args": ["awslabs.aws-iac-mcp-server@latest"],
    "env": {
      "AWS_PROFILE": "your-profile"
    }
  }
}
```

Available AWS MCP servers include:
- `awslabs.aws-iac-mcp-server` - CDK/CloudFormation guidance
- `awslabs.aws-documentation-mcp-server` - AWS docs access
- `awslabs.aws-serverless-mcp-server` - Lambda/SAM workflows

### Context7 (Library Documentation)

For up-to-date library documentation:

```json
{
  "context7": {
    "type": "http",
    "url": "https://mcp.context7.com/mcp"
  }
}
```

Use by adding `use context7` to your prompts or configure auto-invocation rules.

### n8n-mcp (Workflow Automation)

For building n8n workflows programmatically:

```json
{
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
```

**n8n-mcp** provides access to 1,084 n8n nodes, validation, and 2,709 workflow templates. For best results, also install the **n8n-skills**:

```bash
apm install czlonkowski/n8n-skills
```

The 7 n8n skills teach AI agents:
- Correct expression syntax (`{{}}` patterns)
- Effective MCP tool usage
- Proven workflow patterns
- Validation error interpretation
- Node configuration best practices
- Code node patterns (JavaScript/Python)

## Contributing

Found an issue or have a suggestion? Open an issue or PR on [GitHub](https://github.com/chandima/agent-skills).

## License

MIT
