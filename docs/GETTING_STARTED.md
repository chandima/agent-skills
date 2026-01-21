# Getting Started with Agent Skills

This tutorial walks through installing agent-skills in a new project, compiling for OpenCode, and building a todo app using the `@fullstack-developer` agent.

## Prerequisites

- **APM** - Agent Package Manager
  ```bash
  brew install danielmeppiel/tap/apm
  ```

- **OpenCode** - AI coding agent
  ```bash
  brew install anomalyco/tap/opencode
  ```

- **Node.js 20+** - For SST and Astro
  ```bash
  node --version  # v20.x or higher
  ```

- **AWS Credentials** - For SST deployment
  ```bash
  aws configure  # or use SSO
  ```

---

## 1. Create a New Project

```bash
mkdir todo-app && cd todo-app
git init
```

```
Initialized empty Git repository in /Users/you/todo-app/.git/
```

---

## 2. Install Agent Skills

```bash
apm install chandima/agent-skills
```

```
✨ Created apm.yml
Validating 1 package(s)...
✓ chandima/agent-skills - accessible
Added chandima/agent-skills to apm.yml
Installing dependencies from apm.yml...
Installing APM dependencies (1)...
Created .github/ as standard skills root
✓ chandima/agent-skills
  └─ 5 prompts integrated → .github/prompts/
  └─ 5 agents integrated → .github/agents/
  └─ Skill integrated → .github/skills/

Added apm_modules/ to .gitignore
✓ Generated 1 Skill(s)
Installed 1 APM dependencies

╭────────────────────── ✨ Installation complete ──────────────────────────╮
│                                                                          │
│  Next steps:                                                             │
│    apm compile              # Generate AGENTS.md guardrails              │
│    apm run <prompt>         # Execute prompt/workflow                    │
│    apm list                 # Show all prompts                           │
│                                                                          │
╰──────────────────────────────────────────────────────────────────────────╯
```

---

## 3. Compile for OpenCode

APM compiles instructions into `AGENTS.md`, which OpenCode reads automatically.

```bash
apm compile
```

```
⚙️ Starting context compilation...
Compiling for AGENTS.md (VSCode/Copilot) - detected .github/ folder
Analyzing project structure...
├─ 3 directories scanned (max depth: 4)
├─ 6 files analyzed across 2 file types
└─ 11 instruction patterns detected

Optimizing placements...

Generated 2 AGENTS.md files
├─ ./AGENTS.md              10 instructions
└─ .github/AGENTS.md         1 instruction

✅ Compilation completed successfully!
```

---

## 4. Project Structure

```bash
ls -la
```

```
.git/
.github/
  ├── agents/           # 5 agent personas
  │   ├── architect-apm.agent.md
  │   ├── code-reviewer-apm.agent.md
  │   ├── devops-engineer-apm.agent.md
  │   ├── fullstack-developer-apm.agent.md
  │   └── test-engineer-apm.agent.md
  ├── prompts/          # 5 workflow commands
  │   ├── code-review-apm.prompt.md
  │   ├── debug-issue-apm.prompt.md
  │   ├── pr-description-apm.prompt.md
  │   ├── refactor-apm.prompt.md
  │   └── test-plan-apm.prompt.md
  ├── skills/           # On-demand expertise
  └── AGENTS.md
.gitignore
AGENTS.md               # Compiled instructions for AI
apm.yml                 # Package manifest
apm_modules/            # Installed packages
SKILL.md
```

| Component | Purpose |
|-----------|---------|
| `AGENTS.md` | Compiled instructions OpenCode reads |
| `.github/agents/` | Agent personas with tool permissions |
| `.github/prompts/` | Executable workflow commands |
| `.github/skills/` | On-demand expertise modules |
| `apm.yml` | Package dependencies |

---

## 5. Build a Todo App

Start OpenCode:

```bash
opencode
```

### Scaffold the Project

```
You: @fullstack-developer Create a todo app with SST, Astro, and Alpine.js. 
     Use DynamoDB for storage.

Agent: I'll create an SST + Astro todo app with our standard stack.

Creating project structure...
[Creates: sst.config.ts, package.json, tsconfig.json]
[Creates: packages/web/ - Astro frontend]
[Creates: packages/functions/ - Lambda handlers]
[Creates: packages/core/ - Shared types]

Setting up SST infrastructure with DynamoDB table and API routes...

Project scaffolded. Run `npm install` to install dependencies.
```

### Add the UI

```
You: Add the todo list page with Basecoat UI components and Alpine.js

Agent: Creating the todo page with Basecoat card components and Alpine.js 
for reactivity...

[Creates: packages/web/src/pages/index.astro]
```

```astro
---
// packages/web/src/pages/index.astro
import Layout from '../layouts/Layout.astro';
import { Card, Button, Input } from '@basecoat/ui';
---

<Layout title="Todo App">
  <div x-data="todoApp()" class="max-w-md mx-auto p-4">
    <Card>
      <form @submit.prevent="addTodo">
        <Input x-model="newTodo" placeholder="What needs to be done?" />
        <Button type="submit">Add</Button>
      </form>
      
      <ul class="mt-4 space-y-2">
        <template x-for="todo in todos" :key="todo.id">
          <li class="flex items-center gap-2">
            <input type="checkbox" :checked="todo.completed" 
                   @change="toggleTodo(todo.id)">
            <span x-text="todo.text" :class="todo.completed && 'line-through'"></span>
            <Button size="sm" variant="ghost" @click="deleteTodo(todo.id)">×</Button>
          </li>
        </template>
      </ul>
    </Card>
  </div>
</Layout>

<script>
  import Alpine from 'alpinejs';
  
  Alpine.data('todoApp', () => ({
    todos: [],
    newTodo: '',
    
    async init() {
      const res = await fetch('/api/todos');
      this.todos = await res.json();
    },
    
    async addTodo() {
      if (!this.newTodo.trim()) return;
      const res = await fetch('/api/todos', {
        method: 'POST',
        body: JSON.stringify({ text: this.newTodo })
      });
      this.todos.push(await res.json());
      this.newTodo = '';
    },
    
    async toggleTodo(id) { /* ... */ },
    async deleteTodo(id) { /* ... */ }
  }));
</script>
```

### Add API Routes

```
You: Add the API routes for CRUD operations

Agent: Adding API routes with DynamoDB storage...

[Creates: packages/functions/src/todos.ts]
```

```typescript
// packages/functions/src/todos.ts
import { Resource } from "sst";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocument } from "@aws-sdk/lib-dynamodb";

const db = DynamoDBDocument.from(new DynamoDBClient({}));

export async function list() {
  const result = await db.scan({ TableName: Resource.Todos.name });
  return new Response(JSON.stringify(result.Items));
}

export async function create(event: { body: string }) {
  const { text } = JSON.parse(event.body);
  const todo = { id: crypto.randomUUID(), text, completed: false };
  await db.put({ TableName: Resource.Todos.name, Item: todo });
  return new Response(JSON.stringify(todo));
}

export async function remove(event: { pathParameters: { id: string } }) {
  await db.delete({ 
    TableName: Resource.Todos.name, 
    Key: { id: event.pathParameters.id } 
  });
  return new Response(null, { status: 204 });
}
```

### Final Structure

```
todo-app/
├── sst.config.ts              # SST infrastructure
├── package.json
├── packages/
│   ├── web/
│   │   └── src/
│   │       ├── pages/
│   │       │   └── index.astro    # Todo UI with Alpine.js
│   │       └── layouts/
│   │           └── Layout.astro
│   ├── functions/
│   │   └── src/
│   │       └── todos.ts           # API routes
│   └── core/
│       └── src/
│           └── types.ts           # Shared types
├── AGENTS.md
└── apm.yml
```

---

## 6. Load Skills On-Demand

OpenCode can load skills dynamically when needed. Skills provide deep expertise without bloating the base context.

```
You: I want to review my API routes for security issues. 
     Load the security review skill.

Agent: Loading skill: review/security

Applying security detection methodology...

Checking for hardcoded secrets:
  grep -rE "(api[_-]?key|password|secret)" packages/functions/
  ✓ No hardcoded secrets found

Checking for input validation:
  ⚠ packages/functions/src/todos.ts:12 - Missing input validation
  
Recommendation: Add zod schema validation for the request body.
```

### Available Skills

| Domain | Skills |
|--------|--------|
| **review/** | `code`, `security` |
| **testing/** | `strategy`, `e2e` |
| **devops/** | `cicd`, `containers`, `iac`, `security` |
| **architecture/** | `patterns` |
| **stack/** | `sst`, `astro`, `alpine`, `basecoat` |

Load any skill by asking the agent:

```
You: Load the devops/containers skill and review my Dockerfile
You: I need the testing/e2e skill to write Playwright tests
You: Use the architecture/patterns skill to evaluate this design
```

---

## 7. Review Code with /code-review

Prompts are executable workflows that orchestrate skills. Run them with `/`:

```
You: /code-review
```

```
Agent: Running code review workflow...

Loading skills: review/code, review/security

Analyzing: packages/functions/src/todos.ts, packages/web/src/pages/index.astro

## CODE REVIEW REPORT

**Files Reviewed**: 2 files
**Overall Assessment**: Pass with suggestions

### High Priority
| Location | Issue | Recommendation |
|----------|-------|----------------|
| todos.ts:12 | Missing input validation | Add zod schema for request body |
| todos.ts:8 | No error handling | Wrap DynamoDB calls in try/catch |

### Suggestions
- Add loading state to UI while fetching todos
- Consider optimistic updates for better UX
- Add rate limiting to API routes

### Positive Notes
- Clean separation between API and UI
- Good use of Alpine.js for reactivity
- Type-safe SST resource references
```

### Other Prompts

| Command | Purpose |
|---------|---------|
| `/code-review` | Security, bugs, performance review |
| `/pr-description` | Generate PR description from changes |
| `/debug-issue` | Structured debugging workflow |
| `/refactor` | Safe refactoring with test preservation |
| `/test-plan` | Generate comprehensive test cases |

---

## 8. Run the App

Install dependencies and start the SST dev environment:

```bash
npm install
npx sst dev
```

```
SST 3.x

➜ App:     todo-app
  Stage:   dev

✓ Built
✓ Deployed:
  API:     https://abc123.execute-api.us-east-1.amazonaws.com
  Web:     http://localhost:4321
```

Open http://localhost:4321 to see your todo app running.

---

## Next Steps

### Try Other Agents

```
@architect      # System design and trade-off analysis
@code-reviewer  # Read-only code analysis
@test-engineer  # Test coverage and quality
@devops-engineer # CI/CD and infrastructure
```

### Customize

Override any primitive by editing files in `.github/`:

```bash
# Customize an agent
vim .github/agents/fullstack-developer-apm.agent.md

# Add project-specific instructions
echo "# My Rules" > .github/instructions/custom.instructions.md
apm compile
```

### Learn More

- [Framework Architecture](FRAMEWORK.md) - How primitives work together
- [APM Documentation](https://github.com/danielmeppiel/apm) - Package manager docs
- [OpenCode Docs](https://opencode.ai/docs) - OpenCode configuration

---

## Summary

| Step | Command | Result |
|------|---------|--------|
| Create | `mkdir todo-app && git init` | Empty repo |
| Install | `apm install chandima/agent-skills` | Agents, prompts, skills |
| Compile | `apm compile` | AGENTS.md generated |
| Build | `opencode` → `@fullstack-developer` | SST + Astro app |
| Skills | Ask agent to load skills | On-demand expertise |
| Review | `/code-review` | Code analyzed |
| Run | `npx sst dev` | App running |
