---
name: code
description: Code review methodology with prioritized checklists and constructive feedback patterns. Use when reviewing code for quality, correctness, maintainability, and performance.
---

# Code Review

Systematic approach to reviewing code for quality, correctness, and maintainability.

## Review Philosophy

### Be Constructive
Every piece of feedback should:
- Explain **what** the issue is
- Explain **why** it's a problem
- Suggest **how** to fix it
- Include code examples when helpful

```
Bad: "This is wrong"
Good: "This query is vulnerable to SQL injection because user input is 
concatenated directly. Use parameterized queries instead:
db.query('SELECT * FROM users WHERE id = $1', [userId])"
```

### Be Specific
Reference exact file locations and line numbers. Quote the problematic code directly.

```
In `src/auth/login.ts:42`:
The password comparison uses `==` which could allow type coercion:
password == storedHash

Should use strict comparison or a timing-safe comparison:
crypto.timingSafeEqual(Buffer.from(password), Buffer.from(storedHash))
```

## Priority Levels

### Critical (Must Fix)
- Security vulnerabilities
- Data corruption risks
- Breaking bugs in core functionality

### High Priority
- Bugs that affect user experience
- Performance issues in hot paths
- Missing error handling

### Medium Priority
- Code duplication
- Minor performance improvements
- Testability issues

### Low Priority (Suggestions)
- Style preferences beyond standards
- Minor readability improvements
- "Nice to have" enhancements

## Review Checklists

### Correctness
- [ ] Logic handles all expected cases
- [ ] Edge cases considered (null, empty, boundaries)
- [ ] Error conditions handled appropriately
- [ ] Async operations handled correctly
- [ ] No race conditions in concurrent code

### Performance
- [ ] No obvious O(n²) or worse algorithms where avoidable
- [ ] Database queries are efficient (no N+1)
- [ ] No unnecessary work in loops
- [ ] Appropriate use of caching

### Maintainability
- [ ] Code is readable and well-organized
- [ ] Functions/classes have single responsibility
- [ ] Names are descriptive and consistent
- [ ] Comments explain "why" not "what"
- [ ] No code duplication (DRY)

### Testing
- [ ] Critical paths have test coverage
- [ ] Edge cases are tested
- [ ] Tests are meaningful (not just for coverage)

## Communication Style

### Tone
- Professional and respectful
- Assume good intent
- Teach, don't lecture
- Acknowledge good work too

### Output Format

Structure feedback clearly:

```markdown
## Summary
[Overall assessment - 1-2 sentences]

## Critical Issues
[Must be fixed before merge]

## Recommendations
[Should be fixed, high priority]

## Suggestions
[Nice to have improvements]

## Positive Notes
[What was done well]
```

## Example Review Output

```markdown
## Summary
The authentication implementation is functional but has security concerns 
that should be addressed before production use.

## Critical Issues

**1. Password stored in plain text** (`src/auth/user.ts:34`)
```typescript
const user = { email, password: plainPassword }; // Never store plain passwords
```
Use bcrypt with appropriate salt rounds:
```typescript
const hashedPassword = await bcrypt.hash(plainPassword, 12);
const user = { email, password: hashedPassword };
```

## Recommendations

**2. Missing rate limiting on login** (`src/auth/login.ts`)
Add rate limiting to prevent brute force attacks.

## Positive Notes
- Good separation of concerns
- Clean error handling in the registration flow
- Consistent use of async/await
```
