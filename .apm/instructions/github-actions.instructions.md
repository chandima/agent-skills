---
applyTo: ".github/workflows/**/*.{yml,yaml}"
description: "GitHub Actions workflow standards with security, performance, and maintainability best practices"
---

# GitHub Actions Standards

## Workflow Structure

### File Organization

```
.github/
├── workflows/
│   ├── ci.yml              # Main CI pipeline
│   ├── cd.yml              # Deployment pipeline
│   ├── release.yml         # Release automation
│   └── scheduled.yml       # Cron jobs
├── actions/
│   └── setup-project/      # Composite actions
│       └── action.yml
└── dependabot.yml          # Dependency updates
```

### Workflow Naming

- Use descriptive `name:` at workflow and job level
- Job names should describe what they do, not how

```yaml
# Good
name: CI
jobs:
  test:
    name: Run Tests
  lint:
    name: Check Code Quality

# Bad
jobs:
  job1:
    name: npm run test
```

## Triggers

### Event Selection

| Event | Use Case | Considerations |
|-------|----------|----------------|
| `push` | CI on commits | Filter by branch/path |
| `pull_request` | PR validation | Runs on merge commit |
| `workflow_dispatch` | Manual runs | Add inputs for params |
| `schedule` | Cron jobs | Use sparingly, UTC time |
| `release` | Release automation | published, created, etc. |

### Path and Branch Filtering

```yaml
on:
  push:
    branches: [main, develop]
    paths:
      - 'src/**'
      - 'package.json'
      - '.github/workflows/ci.yml'
    paths-ignore:
      - '**.md'
      - 'docs/**'
  
  pull_request:
    branches: [main]
    types: [opened, synchronize, reopened]
```

### Workflow Dispatch Inputs

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - staging
          - production
      dry_run:
        description: 'Dry run mode'
        type: boolean
        default: true
```

## Security

### Permissions (Principle of Least Privilege)

Always declare explicit permissions. Default to minimal access.

```yaml
# Workflow-level defaults
permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps: [...]
  
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write      # For OIDC
      deployments: write   # For deployment status
    steps: [...]
```

### Common Permission Patterns

| Task | Required Permissions |
|------|---------------------|
| Checkout code | `contents: read` |
| Push commits | `contents: write` |
| Create PR comments | `pull-requests: write` |
| OIDC authentication | `id-token: write` |
| Update deployments | `deployments: write` |
| Push packages | `packages: write` |

### OIDC Authentication (Preferred)

Never use long-lived credentials. Use OIDC for cloud providers.

```yaml
jobs:
  deploy:
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      
      # No AWS keys in secrets!
```

### Pin Actions by SHA

Pin third-party actions to full commit SHA, not tags.

```yaml
# Bad - tags can be moved
- uses: actions/checkout@v4

# Good - immutable reference
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1

# First-party actions can use tags
- uses: actions/cache@v4  # Acceptable for actions/*
```

### Secret Handling

```yaml
# Never echo secrets
- run: |
    # Bad - exposed in logs
    echo ${{ secrets.API_KEY }}
    
    # Good - mask if needed
    echo "::add-mask::${{ secrets.API_KEY }}"

# Use environment secrets for sensitive deployments
jobs:
  deploy:
    environment: production  # Requires approval
    steps:
      - run: deploy --token ${{ secrets.PROD_TOKEN }}
```

## Reusable Workflows

### Creating Reusable Workflows

```yaml
# .github/workflows/reusable-build.yml
name: Reusable Build

on:
  workflow_call:
    inputs:
      node-version:
        type: string
        default: '20'
      working-directory:
        type: string
        default: '.'
    secrets:
      npm-token:
        required: false
    outputs:
      artifact-name:
        description: 'Build artifact name'
        value: ${{ jobs.build.outputs.artifact }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      artifact: ${{ steps.upload.outputs.artifact-name }}
    defaults:
      run:
        working-directory: ${{ inputs.working-directory }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci
      - run: npm run build
      - id: upload
        uses: actions/upload-artifact@v4
        with:
          name: build-${{ github.sha }}
          path: ${{ inputs.working-directory }}/dist
```

### Calling Reusable Workflows

```yaml
jobs:
  build:
    uses: ./.github/workflows/reusable-build.yml
    with:
      node-version: '20'
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}
  
  deploy:
    needs: build
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      artifact: ${{ needs.build.outputs.artifact-name }}
```

## Composite Actions

### Creating Composite Actions

```yaml
# .github/actions/setup-project/action.yml
name: Setup Project
description: Install dependencies and setup environment

inputs:
  node-version:
    description: Node.js version
    default: '20'
  install-command:
    description: Package install command
    default: 'npm ci'

runs:
  using: composite
  steps:
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: npm
    
    - name: Install dependencies
      shell: bash
      run: ${{ inputs.install-command }}
    
    - name: Cache build
      uses: actions/cache@v4
      with:
        path: |
          .next/cache
          node_modules/.cache
        key: build-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}
```

### Using Composite Actions

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./.github/actions/setup-project
        with:
          node-version: '20'
      - run: npm test
```

## Caching

### Dependency Caching

```yaml
# Built-in caching (preferred)
- uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: npm  # or pnpm, yarn

# Manual caching for complex cases
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: npm-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      npm-${{ runner.os }}-
```

### Build Caching

```yaml
# Next.js build cache
- uses: actions/cache@v4
  with:
    path: ${{ github.workspace }}/.next/cache
    key: nextjs-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}-${{ hashFiles('**/*.js', '**/*.jsx', '**/*.ts', '**/*.tsx') }}
    restore-keys: |
      nextjs-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}-
      nextjs-${{ runner.os }}-

# Turborepo cache
- uses: actions/cache@v4
  with:
    path: .turbo
    key: turbo-${{ runner.os }}-${{ github.sha }}
    restore-keys: |
      turbo-${{ runner.os }}-
```

## Matrix Strategies

### Basic Matrix

```yaml
jobs:
  test:
    strategy:
      matrix:
        node: [18, 20, 22]
        os: [ubuntu-latest, macos-latest]
      fail-fast: false  # Continue other jobs if one fails
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
```

### Matrix with Include/Exclude

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    node: [18, 20]
    include:
      - os: ubuntu-latest
        node: 22
        experimental: true
    exclude:
      - os: windows-latest
        node: 18
```

### Test Sharding

```yaml
jobs:
  test:
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - run: npm test -- --shard=${{ matrix.shard }}/${{ strategy.job-total }}
```

## Artifacts

### Upload Artifacts

```yaml
- uses: actions/upload-artifact@v4
  with:
    name: coverage-report
    path: coverage/
    retention-days: 14
    if-no-files-found: error
```

### Download Artifacts

```yaml
- uses: actions/download-artifact@v4
  with:
    name: coverage-report
    path: coverage/

# Download all artifacts
- uses: actions/download-artifact@v4
  with:
    path: all-artifacts/
    merge-multiple: true
```

## Job Dependencies and Outputs

### Job Outputs

```yaml
jobs:
  build:
    outputs:
      version: ${{ steps.version.outputs.value }}
    steps:
      - id: version
        run: echo "value=$(cat package.json | jq -r .version)" >> $GITHUB_OUTPUT
  
  deploy:
    needs: build
    steps:
      - run: echo "Deploying version ${{ needs.build.outputs.version }}"
```

### Conditional Jobs

```yaml
jobs:
  deploy:
    needs: [test, lint]
    if: github.ref == 'refs/heads/main' && success()
    
  notify:
    needs: [deploy]
    if: always()  # Run even if deploy fails
    steps:
      - if: needs.deploy.result == 'failure'
        run: echo "Deploy failed!"
```

## Concurrency Control

### Cancel In-Progress Runs

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### Environment Queuing

```yaml
jobs:
  deploy:
    environment: production
    concurrency:
      group: production-deploy
      cancel-in-progress: false  # Queue, don't cancel
```

## Anti-Patterns

### Avoid These Patterns

```yaml
# Bad: No permissions defined (uses permissive defaults)
jobs:
  build:
    runs-on: ubuntu-latest

# Bad: Using latest tag
- uses: actions/checkout@latest

# Bad: Secrets in command line
- run: curl -H "Authorization: ${{ secrets.TOKEN }}" ...

# Bad: No timeout (can run forever)
jobs:
  test:
    runs-on: ubuntu-latest
    # Missing timeout-minutes

# Bad: Hardcoded versions scattered everywhere
- uses: actions/setup-node@v4
  with:
    node-version: '18.17.0'  # Hardcoded in multiple places
```

### Preferred Patterns

```yaml
# Good: Explicit minimal permissions
permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 15

# Good: Pinned SHA
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11

# Good: Secrets via environment
- run: npm publish
  env:
    NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}

# Good: Centralized versions
env:
  NODE_VERSION: '20'
jobs:
  test:
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
```

## Debugging

### Enable Debug Logging

```yaml
env:
  ACTIONS_RUNNER_DEBUG: true
  ACTIONS_STEP_DEBUG: true
```

### Interactive Debugging

```yaml
- name: Debug via SSH
  if: failure()
  uses: mxschmitt/action-tmate@v3
  with:
    limit-access-to-actor: true
```

### Context Inspection

```yaml
- name: Dump contexts
  run: |
    echo "github context:"
    echo '${{ toJson(github) }}'
    echo "env context:"
    echo '${{ toJson(env) }}'
```
