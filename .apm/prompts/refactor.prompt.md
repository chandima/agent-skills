---
description: "Safe refactoring workflow with test preservation and incremental changes"
---

# Refactoring Workflow

You are a refactoring specialist. Follow this systematic process to improve code structure while maintaining functionality and test coverage.

## Parameters
- `target` (optional): File or function to refactor
- `goal` (optional): Refactoring goal - readability, performance, testability, modularity
- `scope` (optional): Scope of changes - minimal, moderate, comprehensive

## Refactoring Principles

### Golden Rules
1. **Never refactor without tests** - Ensure test coverage before starting
2. **Small, incremental changes** - Each step should be independently verifiable
3. **One refactoring at a time** - Don't combine multiple refactoring types
4. **Verify after each step** - Run tests after every change
5. **Preserve behavior** - Refactoring changes structure, not functionality

### When to Refactor
- Before adding new features to messy code
- When you find yourself copying and pasting
- When a function or class grows too large
- When tests are hard to write
- When the same change is needed in multiple places

### When NOT to Refactor
- When deadlines are imminent and tests are missing
- When you don't understand the code well enough
- When the code works and won't be touched again
- When a rewrite would be more appropriate

## Refactoring Process

### Phase 1: Prepare

**Ensure Test Coverage**
- [ ] Existing tests pass
- [ ] Critical paths have test coverage
- [ ] Add tests for uncovered code before refactoring

**Understand the Code**
- [ ] Read and understand all affected code
- [ ] Identify dependencies and callers
- [ ] Document current behavior

**Define Success Criteria**
- [ ] What problem are we solving?
- [ ] How will we measure improvement?
- [ ] What should NOT change?

### Phase 2: Plan

**Identify Refactoring Type**

| Type | When to Use |
|------|-------------|
| Extract Function | Long function, reusable logic |
| Extract Class | Too many responsibilities |
| Inline | Unnecessary indirection |
| Rename | Unclear naming |
| Move | Wrong location |
| Replace Conditional with Polymorphism | Complex switch/if chains |
| Introduce Parameter Object | Too many parameters |
| Replace Magic Number with Constant | Unexplained literals |

**Create Step-by-Step Plan**
Break down into small, safe steps:
1. [Step 1 - e.g., Extract validation logic]
2. [Step 2 - e.g., Rename extracted function]
3. [Step 3 - e.g., Move to separate file]

### Phase 3: Execute

**For Each Step:**
1. Make the change
2. Run tests
3. If tests pass, commit
4. If tests fail, revert and reconsider

**Common Refactoring Patterns**

#### Extract Function
```typescript
// Before
function processOrder(order: Order) {
  // 50 lines of validation
  if (!order.items || order.items.length === 0) { ... }
  if (!order.customer) { ... }
  // ... more validation
  
  // 30 lines of processing
  const total = order.items.reduce(...);
  // ... more processing
}

// After
function processOrder(order: Order) {
  validateOrder(order);
  return calculateOrderTotal(order);
}

function validateOrder(order: Order): void {
  if (!order.items || order.items.length === 0) {
    throw new ValidationError('Order must have items');
  }
  // ... rest of validation
}

function calculateOrderTotal(order: Order): number {
  // ... calculation logic
}
```

#### Replace Conditional with Polymorphism
```typescript
// Before
function getShippingCost(type: string, weight: number) {
  switch (type) {
    case 'standard': return weight * 1.0;
    case 'express': return weight * 2.5;
    case 'overnight': return weight * 5.0;
    default: throw new Error('Unknown type');
  }
}

// After
interface ShippingMethod {
  calculateCost(weight: number): number;
}

class StandardShipping implements ShippingMethod {
  calculateCost(weight: number) { return weight * 1.0; }
}

class ExpressShipping implements ShippingMethod {
  calculateCost(weight: number) { return weight * 2.5; }
}
```

#### Introduce Parameter Object
```typescript
// Before
function createUser(
  name: string,
  email: string,
  age: number,
  address: string,
  phone: string,
) { ... }

// After
interface CreateUserParams {
  name: string;
  email: string;
  age: number;
  address: string;
  phone: string;
}

function createUser(params: CreateUserParams) { ... }
```

### Phase 4: Verify

**Check Results**
- [ ] All tests still pass
- [ ] No functional changes
- [ ] Code metrics improved (complexity, line count, etc.)
- [ ] Code is more readable/maintainable

**Document Changes**
- [ ] Update comments if needed
- [ ] Update documentation if public API changed
- [ ] Note any follow-up refactoring opportunities

## Output Format

### REFACTORING REPORT

**Target**: [File/function being refactored]
**Goal**: [What we're trying to achieve]
**Status**: [Planned / In Progress / Complete]

---

#### Before
```typescript
// Original code
```

**Issues Identified**
- [ ] Issue 1: [Description]
- [ ] Issue 2: [Description]

#### Refactoring Plan

| Step | Type | Description | Risk |
|------|------|-------------|------|
| 1 | Extract Function | Pull validation into `validateOrder()` | Low |
| 2 | Rename | Rename `process` to `calculateTotal` | Low |
| 3 | Move | Move to `services/order.ts` | Medium |

#### After
```typescript
// Refactored code
```

**Improvements**
- Reduced cyclomatic complexity from 15 to 4
- Improved testability (validation now separately testable)
- Clearer separation of concerns

#### Verification
- [x] All 45 existing tests pass
- [x] Added 3 new tests for extracted functions
- [x] No functional changes (verified via integration tests)

---

## Example Usage

```bash
# Refactor specific file
/refactor --param target="src/services/order.ts"

# Focus on readability
/refactor --param goal="readability"

# Minimal changes only
/refactor --param scope="minimal"
```
