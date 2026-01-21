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
  aws sso login --profile <your-profile>  # Recommended: use SSO
  # or: aws configure
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
Updated apm.yml with 1 new package(s)
Installing dependencies from apm.yml...
Installing APM dependencies (1)...
Created .github/ as standard skills root (.github/skills/) and to enable 
VSCode/Copilot integration
✓ chandima/agent-skills
  └─ 5 prompts integrated → .github/prompts/
  └─ 5 agents integrated → .github/agents/
  └─ Skill integrated → .github/skills/

Added apm_modules/ to .gitignore
Updated .gitignore for integrated prompts (*-apm.prompt.md)
Updated .gitignore for integrated agents (*-apm.agent.md, *-apm.chatmode.md)
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
├─ 7 files analyzed across 2 file types (md, yml)
└─ 11 instruction patterns detected

Optimizing placements...

Generated 2 AGENTS.md files
┌─ Context efficiency:    10.0%
└─ Generation time:       24ms

Placement Distribution
├─ .                              10 instructions from 1 source
└─ .github                        1 instruction from 1 source

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
| `apm.yml` | Package dependencies |

---

## 5. Build a Todo App

Start OpenCode:

```bash
opencode
```

> **Note**: The conversations below show example interactions with the agent. 
> Use these as a guide—adapt the prompts to your needs. The agent will create 
> the actual files in your project.

### Scaffold the Project

```
You: @fullstack-developer Create a todo app with SST, Astro, and Alpine.js. 
     Use DynamoDB for storage.

Agent: I'll create an SST + Astro todo app with our standard stack.

Creating project structure...
[Creates: sst.config.ts, package.json, tsconfig.json, astro.config.mjs]
[Creates: src/pages/ - Astro pages and API routes]
[Creates: src/lib/ - Database and shared code]
[Creates: src/layouts/ - Astro layouts]

Setting up SST infrastructure with DynamoDB table and API routes...

Project scaffolded. Run `npm install` to install dependencies.
```

### Add the UI

```
You: Add the todo list page with Basecoat UI components and Alpine.js

Agent: Creating the todo page with Basecoat card components and Alpine.js 
for reactivity...

[Creates: src/pages/index.astro]
```

```astro
---
// src/pages/index.astro
import Layout from '../layouts/Layout.astro';
---

<Layout title="Todo App">
  <div x-data="todoApp()" class="max-w-md mx-auto p-4">
    <div class="card">
      <form @submit.prevent="addTodo" class="flex gap-2">
        <input x-model="newTodo" placeholder="What needs to be done?" 
               class="input flex-1" />
        <button type="submit" class="btn btn-primary">Add</button>
      </form>
      
      <ul class="mt-4 space-y-2">
        <template x-for="todo in todos" :key="todo.id">
          <li class="flex items-center gap-2">
            <input type="checkbox" :checked="todo.completed" 
                   @change="toggleTodo(todo.id)">
            <span x-text="todo.text" :class="todo.completed && 'line-through'"></span>
            <button class="btn btn-ghost btn-sm" @click="deleteTodo(todo.id)">×</button>
          </li>
        </template>
      </ul>
    </div>
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

[Creates: src/lib/db.ts, src/lib/types.ts]
[Creates: src/pages/api/todos/index.ts, src/pages/api/todos/[id].ts]
```

```typescript
// src/lib/db.ts
import { Resource } from "sst";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocument } from "@aws-sdk/lib-dynamodb";

export const db = DynamoDBDocument.from(new DynamoDBClient({}));
export const tableName = Resource.Todos.name;
```

```typescript
// src/pages/api/todos/index.ts
import type { APIRoute } from 'astro';
import { db, tableName } from '../../../lib/db';

export const GET: APIRoute = async () => {
  const result = await db.scan({ TableName: tableName });
  return new Response(JSON.stringify(result.Items));
};

export const POST: APIRoute = async ({ request }) => {
  const { text } = await request.json();
  const todo = { id: crypto.randomUUID(), text, completed: false };
  await db.put({ TableName: tableName, Item: todo });
  return new Response(JSON.stringify(todo));
};
```

```typescript
// src/pages/api/todos/[id].ts
import type { APIRoute } from 'astro';
import { db, tableName } from '../../../lib/db';

export const DELETE: APIRoute = async ({ params }) => {
  await db.delete({ TableName: tableName, Key: { id: params.id } });
  return new Response(null, { status: 204 });
};
```

### Final Structure

```
todo-app/
├── .github/               # APM agents, prompts, skills
├── .sst/                  # SST build output
├── src/
│   ├── layouts/
│   │   └── Layout.astro
│   ├── lib/
│   │   ├── db.ts          # DynamoDB client
│   │   └── types.ts       # Shared types
│   └── pages/
│       ├── api/
│       │   └── todos/
│       │       ├── index.ts   # GET, POST
│       │       └── [id].ts    # DELETE
│       └── index.astro    # Todo UI with Alpine.js
├── AGENTS.md
├── apm.yml
├── astro.config.mjs
├── package.json
├── sst.config.ts          # SST infrastructure
├── tailwind.config.mjs
└── tsconfig.json
```

---

## 6. Review Code with /code-review

Prompts are executable workflows. Run them with `/`:

```
You: /code-review
```

```
Agent: Running code review workflow...

Analyzing: src/pages/api/todos/index.ts, src/pages/index.astro

## CODE REVIEW REPORT

**Files Reviewed**: 2 files
**Overall Assessment**: Pass with suggestions

### High Priority
| Location | Issue | Recommendation |
|----------|-------|----------------|
| index.ts:12 | Missing input validation | Add zod schema for request body |
| index.ts:8 | No error handling | Wrap DynamoDB calls in try/catch |

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

## 7. Run the App

Install dependencies and start the SST dev environment:

```bash
npm install
npx sst dev
```

This starts SST's multiplexer which deploys your infrastructure and runs the Astro dev server locally. You'll see a tabbed interface with:
- **Deploy** - SST infrastructure deployment
- **MyWeb** - Your Astro dev server at http://localhost:4321

```
SST 3.x

➜ App:     todo-app
  Stage:   dev

✓ Built
✓ Deployed:
  API:     https://abc123.execute-api.us-east-1.amazonaws.com
```

Click on **MyWeb** in the sidebar to see the Astro dev server output, then open http://localhost:4321 in your browser.

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
| Install | `apm install chandima/agent-skills` | Agents, prompts |
| Compile | `apm compile` | AGENTS.md generated |
| Build | `opencode` → `@fullstack-developer` | SST + Astro app |
| Review | `/code-review` | Code analyzed |
| Run | `npx sst dev` | App running locally |
