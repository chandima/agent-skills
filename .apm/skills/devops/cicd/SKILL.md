---
name: cicd
description: CI/CD pipeline patterns for GitHub Actions and Jenkins. Covers workflow structure, triggers, security permissions, caching, matrix builds, reusable workflows, and pipeline optimization.
---

# CI/CD Pipeline Patterns

CI/CD pipeline design patterns for automated build, test, and deployment workflows.

## Platform Selection

| Hosting | Recommended Platform |
|---------|---------------------|
| GitHub | GitHub Actions (preferred) |
| GitLab | GitLab CI (built-in) |
| Self-hosted (complex) | Jenkins |
| Self-hosted (simple) | Drone/Woodpecker |

## GitHub Actions Patterns

### Workflow Structure

```yaml
name: CI
on:
  push:
    branches: [main]
    paths: ['src/**', 'package.json']
  pull_request:
    branches: [main]

permissions:
  contents: read  # Minimal by default

jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npm test
```

### Security: Principle of Least Privilege

```yaml
permissions:
  contents: read      # Checkout code
  id-token: write     # OIDC auth
  pull-requests: write # Comment on PRs
```

### OIDC Authentication (Preferred)

```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: us-east-1
# No AWS keys in secrets!
```

### Caching

```yaml
# Built-in (preferred)
- uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: npm

# Manual for complex cases
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: npm-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}
```

### Matrix Builds

```yaml
strategy:
  matrix:
    node: [18, 20, 22]
    os: [ubuntu-latest, macos-latest]
  fail-fast: false
runs-on: ${{ matrix.os }}
```

### Reusable Workflows

```yaml
# .github/workflows/reusable-build.yml
on:
  workflow_call:
    inputs:
      node-version:
        type: string
        default: '20'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
```

### Concurrency Control

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

## Jenkins Patterns

### Declarative Pipeline

```groovy
pipeline {
    agent any
    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    stages {
        stage('Build') {
            steps { sh 'npm ci && npm run build' }
        }
        stage('Test') {
            steps { sh 'npm test' }
        }
        stage('Deploy') {
            when { branch 'main' }
            steps { sh './deploy.sh' }
        }
    }
    post {
        always { cleanWs() }
        failure { slackSend(channel: '#builds', message: "Build failed") }
    }
}
```

### Parallel Stages

```groovy
stage('Tests') {
    parallel {
        stage('Unit') { steps { sh 'npm run test:unit' } }
        stage('Integration') { steps { sh 'npm run test:integration' } }
    }
}
```

### Credentials Handling

```groovy
withCredentials([
    usernamePassword(credentialsId: 'docker-creds',
        usernameVariable: 'USER', passwordVariable: 'PASS')
]) {
    sh 'echo $PASS | docker login -u $USER --password-stdin'
}
```

## Pipeline Optimization

| Problem | Solution |
|---------|----------|
| Slow dependencies | Cache + lockfiles |
| Large Docker images | Multi-stage builds |
| Sequential tests | Parallel/sharding |
| Full rebuilds | Incremental builds |
| Slow checkout | `fetch-depth: 1` |

## Security Checklist

- [ ] Explicit `permissions:` block (minimal)
- [ ] OIDC over long-lived credentials
- [ ] Pin actions by SHA (third-party)
- [ ] Environment protection rules for prod
- [ ] No secrets in logs (`::add-mask::`)
- [ ] Dependabot for action updates

## Anti-Patterns

| Bad | Good |
|-----|------|
| No permissions defined | Explicit minimal permissions |
| `uses: action@latest` | Pin by SHA or version |
| Secrets in CLI args | Environment variables |
| No timeout | `timeout-minutes: 15` |
| Hardcoded versions | Centralized in env vars |

> **Full Reference**: See `.apm/instructions/github-actions.instructions.md` and `.apm/instructions/jenkins.instructions.md` for complete details.
