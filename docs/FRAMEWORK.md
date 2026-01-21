# AI-Native Development Framework

This document explains the core philosophy behind the APM (Agent Package Manager) primitive files and how they work together to create reliable, reusable, and scalable AI workflows.

## Overview

The AI-Native Development framework has **three layers**:

1. **Markdown Prompt Engineering** — Structuring natural language into repeatable, formalized AI instructions
2. **Agent Primitives** — Reusable building blocks that encode structured guidance into modular files
3. **Context Engineering** — Strategic management of what information is loaded (and when) to maximize reliability

Every primitive file plays a specific role in this layered system.

---

## APM Primitives Explained

### 1. Instructions (.instructions.md) — *Guardrails & Standards*

**What they are:**
- Structured Markdown files with rules, standards, and domain-specific guidance
- Include metadata such as `applyTo` to scope when they're relevant (e.g., for TypeScript files)

**Purpose:**
- Encode *contextual guardrails* — coding standards, best practices, safety policies
- Define the stable context that all prompts and agents should respect

**When loaded:**
- Always or scoped by file pattern (e.g., `applyTo: "**/*.ts"`)

**Analogy:**
> *"What the AI must consider before acting."*

**Example:**
```markdown
---
applyTo: "**/*.ts"
description: "TypeScript coding standards"
---

# TypeScript Standards

- Use strict type checking
- Avoid `any` type
- Prefer interfaces over type aliases for objects
```

---

### 2. Prompts (.prompt.md) — *Executable Workflows*

**What they are:**
- Markdown prompt templates that implement complete task *workflows*
- Step-by-step instructions combined with validations and structured reasoning

**Purpose:**
- Encapsulate *procedural logic* for specific tasks (code review, PR description, debugging)
- Implement reusable, executable agentic workflows

**When loaded:**
- Task invocation (e.g., `/code-review`, `/pr-description`)

**Analogy:**
> *"What the AI should do to accomplish a particular task."*

**Example:**
```markdown
---
description: "Systematic code review workflow"
mode: code-reviewer
skills:
  - review/code
  - review/security
---

# Code Review Workflow

## Process
1. Gather context from PR description
2. Apply loaded skills systematically
3. Prioritize findings by severity
4. Generate structured report
```

---

### 3. Agents (.agent.md) — *Agent Personas & Behaviors*

**What they are:**
- Definitions of specific agent personas with associated behaviors and tool permissions
- Shape *how* an AI agent behaves and what it can access

**Purpose:**
- Bundle identity + execution style + relevant skills into a coherent configuration
- Define tool access (read-only vs. full access)

**When loaded:**
- Session start or when invoking an agent (e.g., `@code-reviewer`)

**Analogy:**
> *"Who (or what role) the AI is acting as."*

**Example:**
```markdown
---
description: "Code reviewer focused on quality and security"
mode: subagent
tools:
  read: true
  write: false
  bash: false
skills:
  - review/code
  - review/security
---

# Code Reviewer Agent

You are an expert code reviewer. Your role is read-only analysis.

## Identity
- **Role**: Read-only code analyst
- **Expertise**: Bugs, security, performance, code quality
```

---

### 4. Skills (SKILL.md) — *Reusable Capabilities & Knowledge*

**What they are:**
- Composable, on-demand knowledge packages
- Teach agents how to handle *specialized capabilities*

**Purpose:**
- Provide deep task knowledge and reusable expertise
- Load progressively to prevent context overload
- Complement prompts with detailed methodology

**When loaded:**
- Task-triggered, only when relevant to the current work

**Analogy:**
> *"What the AI can do when a task matches a known capability."*

**Example:**
```markdown
---
name: security
description: "Security vulnerability detection methodology"
---

# Security Review Methodology

This skill teaches HOW TO FIND security vulnerabilities.

## Detection Patterns

### SQL Injection Detection
**Search patterns:**
\`\`\`bash
grep -rE "SELECT.*\+" --include="*.ts"
\`\`\`

**Red flags:**
- String concatenation in queries
- Template literals with user input
```

---

### 5. Context (.context.md) — *Information & Memory Helpers*

**What they are:**
- Files holding *project knowledge* that is not procedural
- Architecture summaries, domain models, API docs, memory snippets

**Purpose:**
- Supply static or semi-structured knowledge for reference
- Reduce cognitive overhead by separating reference data from instructions

**When loaded:**
- As needed during execution

**Analogy:**
> *"What the AI can look up to make informed decisions."*

---

## How Primitives Work Together

The files form a *pipeline* of agent intelligence:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│  1. Instructions      Define stable principles and rules                │
│         ↓                                                               │
│  2. Agent             Shapes behavior profile and tool access           │
│         ↓                                                               │
│  3. Prompt            Executes workflow guided by instructions + agent  │
│         ↓                                                               │
│  4. Skills            Activated on-demand for deep domain knowledge     │
│         ↓                                                               │
│  5. Context           Provides reference data during reasoning          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Example Flow: Code Review

1. **Instructions** (`security.instructions.md`) — Always loaded, defines "never commit secrets"
2. **Agent** (`code-reviewer.agent.md`) — Defines read-only access, professional tone
3. **Prompt** (`code-review.prompt.md`) — Orchestrates the review workflow
4. **Skills** (`review/security`) — Loaded for detection patterns and grep commands
5. **Context** (project docs) — Referenced for architecture understanding

---

## Key Distinction: Instructions vs. Skills

This is the most important distinction to understand:

| Aspect | Instructions | Skills |
|--------|--------------|--------|
| **Purpose** | HOW TO WRITE code | HOW TO FIND/DETECT issues |
| **When loaded** | Auto-applied by file pattern | On-demand when reviewing |
| **Content type** | Coding rules, patterns, examples | Detection methodology, grep patterns |
| **Example** | "Always use parameterized queries" | "Find SQL injection by grepping for string concatenation" |

### Why This Matters

**Instructions** are guardrails that apply when the AI is *writing* code:
```markdown
# security.instructions.md
Always use parameterized queries:
const user = await db.query('SELECT * FROM users WHERE id = $1', [id]);
```

**Skills** are methodology that applies when the AI is *reviewing* code:
```markdown
# review/security/SKILL.md
## Finding SQL Injection
Search patterns:
grep -rE "SELECT.*\+" --include="*.ts"

Red flags:
- String concatenation in query strings
- Template literals with variables
```

---

## Benefits of This Architecture

| Benefit | How It's Achieved |
|---------|-------------------|
| **Repeatable** | Structured primitives replace ad-hoc freeform prompts |
| **Reliable** | Instructions guard against unpredictable responses |
| **Composable** | Skills and context can be shared across projects |
| **Efficient** | Modular context loading avoids context overload |
| **Maintainable** | Each primitive has a single responsibility |

---

## Summary Table

| Primitive | Main Role | Runs When | Synergy Function |
|-----------|-----------|-----------|------------------|
| **.instructions.md** | Rules & guardrails | Always/Scoped | Sets context policies |
| **.prompt.md** | Workflows | Task invocation | Workflow execution logic |
| **.agent.md** | Agent persona | Session start | Shaping agent behavior |
| **SKILL.md** | Capabilities | Task-triggered | Deep specialized knowledge |
| **.context.md** | Reference & memory | As needed | Information retrieval |

---

## Further Reading

- [AI Native Development Guide](https://danielmeppiel.github.io/awesome-ai-native/docs/concepts/) — Core concepts
- [Agent Skills Specification](https://agentskills.io/what-are-skills) — Skills standard
- [APM Documentation](https://github.com/danielmeppiel/apm) — Package manager docs
- [Context Engineering (GitHub Blog)](https://github.blog/ai-and-ml/github-copilot/how-to-build-reliable-ai-workflows-with-agentic-primitives-and-context-engineering/) — Building reliable AI workflows
