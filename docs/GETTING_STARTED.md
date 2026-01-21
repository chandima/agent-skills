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
| `.github/prompts/` | Workflow templates (reference material) |
| `.github/skills/` | On-demand skills loaded via `@` |
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

## 6. Review Code with Skills

APM installs reusable skills that OpenCode can load on demand. Use `@` to reference a skill:

```
You: @review Review the todo app code
```

Type `@review` and OpenCode will show matching skills you can select:
- `.github/skills/agent-skills/.apm/skills/review/code/` - Code quality review
- `.github/skills/agent-skills/.apm/skills/review/security/` - Security review

The agent reads the skill, analyzes your code, and produces a structured review:

```
Agent: I'll perform a code review using the code review methodology.

Reading src/lib/types.ts, sst.config.ts, src/pages/index.astro...

## Code Review: Todo App

### Summary
Well-structured app with good separation of concerns and proper TypeScript 
typing. A few improvements to address around performance and accessibility.

### Recommendations

1. **Sequential deletion in clearCompleted** (index.astro:143)
   Deletes todos one by one. Use `Promise.all` for parallel deletion.

2. **Missing focus trap on dialog** (index.astro:336)
   Add `x-trap.inert` for accessibility.

3. **Unpinned Alpine.js CDN version** (Layout.astro:20)
   Pin to specific version: `alpinejs@3.14.3`

### Suggestions
- Add optimistic UI updates for better UX
- Add `aria-live` region for screen reader announcements

### Positive Notes
- Clean architecture with good separation of concerns
- Proper TypeScript interfaces for all data structures
- Smart DynamoDB design with timestamp-based sort keys

Would you like me to implement any of these fixes?
```

### Available Skills

| Skill | Purpose |
|-------|---------|
| `review/code` | Code quality, bugs, performance |
| `review/security` | Security vulnerability detection |
| `stack/sst` | SST infrastructure patterns |
| `stack/astro` | Astro component patterns |
| `stack/alpine` | Alpine.js reactivity patterns |

---

## 7. Run the App

Install dependencies and start the SST dev environment. You can run terminal commands directly in OpenCode by prefixing with `!`:

```
You: !npm install
```

The generated `package.json` uses `concurrently` to run SST and Astro dev in parallel:

```json
{
  "scripts": {
    "dev": "concurrently \"sst dev\" \"astro dev\"",
    "build": "astro build",
    "remove": "sst remove --stage dev"
  },
  "devDependencies": {
    "concurrently": "^9.2.1"
  }
}
```

Now start the dev environment:

```
You: !npm run dev
```

> **Note**: If you use AWS SSO or named profiles, set your profile before running:
> ```
> !AWS_PROFILE=your-profile npm run dev
> ```

This runs SST (deploying infrastructure) and Astro dev server concurrently. You'll see interleaved output from both processes:

```
[0] SST 3.x
[0] ➜ App:     todo-app
[0]   Stage:   dev
[0] ✓ Complete
[1] 🚀 astro v5.0.0 started
[1]   Local: http://localhost:4321/
```

Open `http://localhost:4321/` in your browser.

---

## Next Steps

### Try Other Skills

Use `@` to load skills on demand:

```
@review         # Code review methodology
@stack/sst      # SST infrastructure patterns
@stack/astro    # Astro component patterns  
@stack/alpine   # Alpine.js reactivity patterns
```

### Use Agent Personas

Reference agent personas for specialized tasks:

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
| Install | `apm install chandima/agent-skills` | Skills installed |
| Compile | `apm compile` | AGENTS.md generated |
| Build | `@fullstack-developer` | SST + Astro app |
| Review | `@review` | Code analyzed |
| Run | `!npm run dev` | App running locally |
