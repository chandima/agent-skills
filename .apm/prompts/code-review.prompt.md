---
description: "Systematic code review for bugs, security vulnerabilities, and performance issues"
mode: code-reviewer
skills:
  - review/code
  - review/security
---

# Code Review Workflow

You are conducting a thorough code review. This prompt orchestrates the review process using loaded skills.

## Parameters

- `files` (optional): Specific files or directories to review
- `focus` (optional): Area of focus - security, performance, bugs, style, or all
- `severity` (optional): Minimum severity to report - critical, high, medium, low

## Process

### 1. Gather Context

First, understand what the code is trying to accomplish:

1. Read any associated PR description or commit messages
2. Identify the primary purpose and business logic
3. List related files and dependencies affected

### 2. Apply Skills

Based on the `focus` parameter, apply the appropriate review methodologies:

| Focus | Skills to Apply |
|-------|-----------------|
| `security` | `review/security` |
| `bugs` or `all` | `review/code` |
| `performance` | `review/code` (performance checklist) |
| `style` | `review/code` (maintainability checklist) |

For each skill:
- Follow the detection patterns
- Use the search commands to find issues
- Apply the checklist systematically

### 3. Prioritize Findings

Categorize issues by severity:

| Severity | Criteria |
|----------|----------|
| **Critical** | Security vulnerabilities, data corruption, breaking bugs |
| **High** | User-facing bugs, performance in hot paths, missing error handling |
| **Medium** | Code duplication, minor performance, testability |
| **Low** | Style preferences, minor readability |

Filter by the `severity` parameter if specified.

### 4. Generate Report

Format the output as follows:

---

## CODE REVIEW REPORT

**Files Reviewed**: [List files]
**Review Focus**: [Focus area or "comprehensive"]
**Overall Assessment**: [Pass / Pass with suggestions / Needs changes]

---

### Critical Issues (Must Fix)

| Location | Issue | Recommendation |
|----------|-------|----------------|
| `file.ts:42` | [Description] | [How to fix] |

### High Priority

| Location | Issue | Recommendation |
|----------|-------|----------------|
| `file.ts:87` | [Description] | [How to fix] |

### Medium Priority

| Location | Issue | Recommendation |
|----------|-------|----------------|
| `file.ts:123` | [Description] | [How to fix] |

### Suggestions (Optional Improvements)

- [Suggestion 1]
- [Suggestion 2]

---

### Summary

- **Security**: [X issues found / No issues]
- **Bugs**: [X issues found / No issues]
- **Performance**: [X issues found / No issues]
- **Code Quality**: [Good / Needs improvement]

### Recommended Actions

1. [First priority action]
2. [Second priority action]

---

## Example Usage

```bash
# Review all staged changes
/code-review

# Review specific files
/code-review --param files="src/auth/"

# Focus on security only
/code-review --param focus="security"

# Only report critical and high issues
/code-review --param severity="high"
```
