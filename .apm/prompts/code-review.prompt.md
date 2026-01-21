---
description: "Systematic code review for bugs, security vulnerabilities, and performance issues"
mode: code-reviewer
---

# Code Review Workflow

You are conducting a thorough code review. Follow this systematic process to identify issues and provide actionable feedback.

## Parameters
- `files` (optional): Specific files or directories to review
- `focus` (optional): Area of focus - security, performance, bugs, style, or all
- `severity` (optional): Minimum severity to report - critical, high, medium, low

## Review Process

### 1. Understand Context
First, understand what the code is trying to accomplish:
- Read any associated PR description or commit messages
- Identify the primary purpose and business logic
- Note any related files or dependencies

### 2. Security Review
Check for security vulnerabilities:

**Authentication & Authorization**
- [ ] Are all endpoints properly authenticated?
- [ ] Is authorization checked for each resource access?
- [ ] Are there any IDOR vulnerabilities?

**Input Validation**
- [ ] Is all user input validated and sanitized?
- [ ] Are SQL queries parameterized?
- [ ] Is output properly escaped to prevent XSS?

**Secrets Management**
- [ ] Are there any hardcoded secrets, API keys, or passwords?
- [ ] Are sensitive values properly handled (not logged, not exposed)?

**Dependencies**
- [ ] Are dependencies up to date?
- [ ] Are there known vulnerabilities in dependencies?

### 3. Bug Detection
Look for common bugs:

**Logic Errors**
- [ ] Are boundary conditions handled correctly?
- [ ] Are null/undefined cases handled?
- [ ] Are error cases handled appropriately?

**Race Conditions**
- [ ] Are there potential race conditions in async code?
- [ ] Is shared state properly synchronized?

**Resource Management**
- [ ] Are resources (connections, files, etc.) properly closed?
- [ ] Are there potential memory leaks?

### 4. Performance Review
Identify performance issues:

**Algorithmic Complexity**
- [ ] Are there O(n²) or worse algorithms that could be improved?
- [ ] Are there unnecessary iterations or redundant operations?

**Database Queries**
- [ ] Are there N+1 query problems?
- [ ] Are queries properly indexed?
- [ ] Is data fetched efficiently (no over-fetching)?

**Resource Usage**
- [ ] Are large operations batched appropriately?
- [ ] Is caching used where beneficial?
- [ ] Are there unnecessary network calls?

### 5. Code Quality
Evaluate maintainability:

**Readability**
- [ ] Are variable and function names descriptive?
- [ ] Is the code well-organized and easy to follow?
- [ ] Are complex sections commented appropriately?

**Design Patterns**
- [ ] Is the code DRY (Don't Repeat Yourself)?
- [ ] Are responsibilities properly separated?
- [ ] Is the code testable?

**Type Safety**
- [ ] Are types properly defined and used?
- [ ] Are there any `any` types that should be more specific?

## Output Format

### CODE REVIEW REPORT

**Files Reviewed**: [List of files]
**Review Focus**: [Focus area]
**Overall Assessment**: [Pass / Pass with suggestions / Needs changes]

---

#### Critical Issues (Must Fix)
| Location | Issue | Recommendation |
|----------|-------|----------------|
| `file.ts:42` | SQL injection vulnerability | Use parameterized query |

#### High Priority
| Location | Issue | Recommendation |
|----------|-------|----------------|
| `file.ts:87` | Unhandled null case | Add null check before access |

#### Medium Priority
| Location | Issue | Recommendation |
|----------|-------|----------------|
| `file.ts:123` | N+1 query problem | Use eager loading or batch query |

#### Suggestions (Optional Improvements)
- Consider extracting validation logic to a separate function
- Variable name `x` could be more descriptive

---

#### Summary
- **Security**: [Issues found / No issues]
- **Bugs**: [Issues found / No issues]
- **Performance**: [Issues found / No issues]
- **Code Quality**: [Good / Needs improvement]

#### Recommended Actions
1. [First priority action]
2. [Second priority action]

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
