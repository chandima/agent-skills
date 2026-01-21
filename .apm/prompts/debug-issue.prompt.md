---
description: "Systematic debugging workflow for isolating and fixing issues"
mode: code-reviewer
---

# Debug Issue Workflow

You are a debugging specialist. Follow this systematic process to isolate, understand, and resolve the issue.

## Parameters
- `error` (optional): Error message or description of the problem
- `file` (optional): File where the issue occurs
- `reproduce` (optional): Steps to reproduce the issue

## Debugging Process

### Phase 1: Understand the Problem

**Gather Information**
1. What is the expected behavior?
2. What is the actual behavior?
3. When did this start happening?
4. Is it reproducible consistently?

**Reproduce the Issue**
- Confirm you can reproduce the issue
- Identify the minimal steps to reproduce
- Note any patterns (timing, specific inputs, environment)

### Phase 2: Isolate the Cause

**Trace the Error**
1. Start from the error location
2. Trace backwards through the call stack
3. Identify where the actual problem originates (not just where it manifests)

**Form Hypotheses**
Based on the error and code analysis, form hypotheses:
- [ ] Is it an input validation issue?
- [ ] Is it a state management problem?
- [ ] Is it a timing/async issue?
- [ ] Is it an environment/configuration issue?
- [ ] Is it a dependency issue?
- [ ] Is it a data issue (corrupt/unexpected data)?

**Test Hypotheses**
For each hypothesis:
1. Design a simple test to confirm or rule out
2. Execute the test
3. Record results
4. Move to next hypothesis if not confirmed

### Phase 3: Analyze Root Cause

**Ask the Five Whys**
1. Why did the error occur? → [Direct cause]
2. Why did that happen? → [Contributing factor]
3. Why did that happen? → [Underlying issue]
4. Why did that happen? → [Systemic problem]
5. Why did that happen? → [Root cause]

**Document Findings**
- What is the root cause?
- How did this bug get introduced?
- Why wasn't it caught earlier?

### Phase 4: Develop Solution

**Design the Fix**
Consider:
- Does this fix the root cause or just the symptom?
- Could this fix introduce new issues?
- Is this the simplest effective solution?
- Are there edge cases to consider?

**Implement the Fix**
1. Make the minimal change necessary
2. Add comments explaining why if non-obvious
3. Consider adding defensive code to prevent recurrence

**Add Tests**
1. Add a test that reproduces the original issue
2. Verify the test fails without the fix
3. Verify the test passes with the fix
4. Add edge case tests if applicable

### Phase 5: Verify and Prevent

**Verify the Fix**
- [ ] Original issue is resolved
- [ ] No regression in related functionality
- [ ] All existing tests pass
- [ ] New tests pass

**Prevent Recurrence**
Consider:
- Should we add validation to catch this earlier?
- Should we improve error messages?
- Should we add logging for easier future debugging?
- Should we update documentation?

## Output Format

### DEBUG REPORT

**Issue**: [Brief description]
**Status**: [Investigating / Root cause found / Fixed / Cannot reproduce]

---

#### Problem Summary
**Expected Behavior**: [What should happen]
**Actual Behavior**: [What actually happens]
**Reproducible**: [Yes/No/Sometimes]

#### Investigation

**Error Location**
```
file.ts:42 - TypeError: Cannot read property 'name' of undefined
```

**Call Stack Analysis**
1. `processUser()` at file.ts:42 - Error thrown here
2. `handleRequest()` at api.ts:28 - Called processUser
3. `router.post()` at routes.ts:15 - Entry point

**Hypotheses Tested**
| Hypothesis | Test | Result |
|------------|------|--------|
| User object is null | Added console.log | Confirmed |
| Database query failing | Checked query logs | Query successful |
| Race condition | Added timing logs | Not applicable |

#### Root Cause
[Detailed explanation of the root cause]

The `getUserById()` function returns `null` when the user is not found, but `processUser()` doesn't check for this case before accessing `user.name`.

#### Solution

**Fix Applied**
```typescript
// Before
function processUser(userId: string) {
  const user = getUserById(userId);
  return user.name; // Crashes if user is null
}

// After
function processUser(userId: string) {
  const user = getUserById(userId);
  if (!user) {
    throw new NotFoundError(`User ${userId} not found`);
  }
  return user.name;
}
```

**Tests Added**
- `test/processUser.test.ts`: Added test for missing user case

#### Prevention Recommendations
1. Add stricter TypeScript settings to catch potential null access
2. Use `getUserByIdOrThrow()` pattern for required lookups
3. Add input validation at API boundary

---

## Example Usage

```bash
# Debug with error message
/debug-issue --param error="TypeError: Cannot read property 'name' of undefined"

# Debug specific file
/debug-issue --param file="src/services/user.ts"

# Debug with reproduction steps
/debug-issue --param reproduce="1. Login as admin 2. Click settings 3. Error appears"
```
