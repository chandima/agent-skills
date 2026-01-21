---
name: cicd
description: CI/CD pipeline review methodology. Use when auditing GitHub Actions, Jenkins, or other pipelines for security, efficiency, and best practices. Focuses on HOW TO REVIEW pipelines, not how to write them.
---

# CI/CD Pipeline Review Methodology

This skill teaches you HOW TO REVIEW CI/CD pipelines. For HOW TO WRITE pipelines, see `.apm/instructions/github-actions.instructions.md` and `.apm/instructions/jenkins.instructions.md`.

## Pipeline Audit Approach

### 1. Security Review

#### Permission Analysis

**What to look for:**
- Missing or overly permissive `permissions:` block
- Write permissions granted unnecessarily
- Secrets accessible to PR workflows from forks

**Detection patterns:**
```bash
# Find workflows without explicit permissions
grep -L "permissions:" .github/workflows/*.yml

# Find overly permissive workflows
grep -rE "permissions:\s*write-all" .github/workflows/
grep -rE "contents:\s*write" .github/workflows/

# Find workflows triggered by pull_request that have write permissions
# (potential security risk from fork PRs)
```

**Red flags:**
- No `permissions:` block (defaults to permissive)
- `permissions: write-all`
- `contents: write` on PR-triggered workflows
- `pull_request_target` with checkout of PR code

#### Secret Exposure

**What to look for:**
- Secrets passed as command line arguments
- Secrets echoed or logged
- Secrets accessible in untrusted contexts

**Detection patterns:**
```bash
# Find secrets in command arguments (exposed in logs)
grep -rE "run:.*\\\$\{\{ secrets\." .github/workflows/
grep -rE "with:.*\\\$\{\{ secrets\." .github/workflows/

# Find potential secret logging
grep -rE "echo.*\\\$\{\{ secrets" .github/workflows/
```

**Red flags:**
- `run: curl -H "Authorization: ${{ secrets.TOKEN }}"`
- Missing `::add-mask::` for dynamic secrets
- Secrets in workflow outputs

#### Action Pinning

**What to look for:**
- Third-party actions using tags instead of SHA
- Actions from untrusted sources
- Outdated action versions

**Detection patterns:**
```bash
# Find actions not pinned by SHA
grep -rE "uses:.*@v[0-9]" .github/workflows/
grep -rE "uses:.*@latest" .github/workflows/
grep -rE "uses:.*@main" .github/workflows/

# List all third-party actions (non-actions/*)
grep -rE "uses: (?!actions/)" .github/workflows/
```

**Red flags:**
- `uses: third-party/action@v1` (tag can be moved)
- `uses: action@latest` or `@main`
- Actions from personal accounts vs organizations

---

### 2. Efficiency Review

#### Build Time Analysis

**What to look for:**
- Missing caching for dependencies
- Sequential jobs that could run in parallel
- Unnecessary full checkouts
- Redundant setup steps

**Detection patterns:**
```bash
# Check for missing cache usage
grep -L "cache:" .github/workflows/*.yml
grep -L "actions/cache" .github/workflows/*.yml

# Find full checkouts (slow for large repos)
grep -rE "checkout@" .github/workflows/ | grep -v "fetch-depth"

# Find jobs without timeout
grep -L "timeout-minutes:" .github/workflows/*.yml
```

**Red flags:**
- `npm ci` without caching
- `fetch-depth: 0` (full clone) when not needed
- Sequential jobs with no dependencies
- Missing `timeout-minutes` (can run forever)

#### Resource Usage

**What to look for:**
- Large matrix builds that could be reduced
- Heavy jobs running on every push
- Missing concurrency controls

**Detection patterns:**
```bash
# Find large matrices
grep -A5 "matrix:" .github/workflows/*.yml

# Find missing concurrency controls
grep -L "concurrency:" .github/workflows/*.yml

# Find workflows without path filters
grep -L "paths:" .github/workflows/*.yml
```

---

### 3. Reliability Review

#### Failure Handling

**What to look for:**
- Missing error handling in scripts
- No retry logic for flaky operations
- Missing status checks

**Detection patterns:**
```bash
# Find run commands without error handling
grep -rE "run: \|$" .github/workflows/  # Multi-line without set -e

# Find network operations without retry
grep -rE "(curl|wget|npm publish)" .github/workflows/
```

**Red flags:**
- Multi-line scripts without `set -e`
- Network calls without retry logic
- No notification on failure
- Missing `if: always()` for cleanup steps

#### Reproducibility

**What to look for:**
- Unpinned tool versions
- Implicit defaults that could change
- Missing lockfiles usage

**Detection patterns:**
```bash
# Find unpinned versions
grep -rE "node-version: ['\"]?[0-9]+['\"]?$" .github/workflows/  # "20" vs "20.10.0"
grep -rE "python-version: ['\"]?[0-9]+\.[0-9]+['\"]?$" .github/workflows/

# Find npm install instead of ci
grep -rE "npm install$" .github/workflows/
```

---

### 4. Jenkins-Specific Review

**What to look for:**
- Jenkinsfile without `pipeline { }` declarative syntax
- Missing timeout/retry blocks
- Credentials used without withCredentials
- Agent running as root

**Detection patterns:**
```bash
# Find scripted pipeline (less maintainable)
grep -L "pipeline {" Jenkinsfile*

# Find credentials issues
grep -rE "env\.[A-Z_]*PASSWORD" Jenkinsfile*
grep -rE 'sh.*\$[A-Z_]*PASSWORD' Jenkinsfile*
```

**Red flags:**
- `agent any` without restrictions
- Missing `options { timeout() }`
- Hardcoded credentials
- No `post { always { cleanWs() } }`

---

## Review Checklist

### GitHub Actions Quick Audit
- [ ] Explicit `permissions:` block with minimal permissions
- [ ] Third-party actions pinned by SHA
- [ ] Secrets not passed in command arguments
- [ ] Caching enabled for dependencies
- [ ] `timeout-minutes` set on all jobs
- [ ] Concurrency control configured
- [ ] Path filters to avoid unnecessary runs

### Security Deep Dive
- [ ] No `pull_request_target` with PR checkout
- [ ] OIDC used instead of long-lived credentials
- [ ] Environment protection for production
- [ ] Secrets not accessible from fork PRs
- [ ] Action sources audited and trusted

---

## Output Format

When reporting pipeline issues:

```markdown
## Pipeline Review: `.github/workflows/ci.yml`

### Security Issues
| Severity | Issue | Location | Fix |
|----------|-------|----------|-----|
| HIGH | No permissions block | Line 1 | Add explicit `permissions: contents: read` |
| MEDIUM | Action not pinned | Line 23 | Pin to SHA: `action@abc123` |

### Efficiency Issues
| Issue | Impact | Recommendation |
|-------|--------|----------------|
| Missing cache | +2min per run | Add `cache: npm` to setup-node |
| No path filter | Runs on README changes | Add `paths: ['src/**']` |

### Recommendations
1. [Most critical fix]
2. [Second priority]
```

---

> **Reference**: For pipeline syntax and patterns, see `.apm/instructions/github-actions.instructions.md` and `.apm/instructions/jenkins.instructions.md`
