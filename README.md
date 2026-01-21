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

## What's Included

### Instructions (Coding Standards)

| File | Applies To | Purpose |
|------|------------|---------|
| `typescript.instructions.md` | `**/*.{ts,tsx}` | Strict types, no `any`, explicit returns |
| `astro.instructions.md` | `**/*.astro` | Component structure, Tailwind, accessibility |
| `json-schema.instructions.md` | `**/*.schema.json` | Draft-04 compatibility, `$ref` patterns |
| `git.instructions.md` | All files | Commit format, PR guidelines, branch naming |
| `security.instructions.md` | All code files | No secrets, input validation, dependency checks |

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
```

## Customization

After installing, you can customize any file in your project's `.apm/` directory. Your local changes take precedence over the package defaults.

## Dependencies

This package includes:
- `vercel-labs/agent-browser` - Browser automation capabilities for E2E testing

## MCP Server Compatibility

This skills package is designed to work alongside MCP (Model Context Protocol) servers for enhanced AI agent capabilities. Install these in your consuming project based on your workflow needs.

### Recommended MCP Servers

| Server | Use Case | Benefits |
|--------|----------|----------|
| **GitHub MCP** | Code review, PR workflows | PR context, issue tracking, code search across repos |
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

## Contributing

Found an issue or have a suggestion? Open an issue or PR on [GitHub](https://github.com/chandima/agent-skills).

## License

MIT
