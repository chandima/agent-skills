---
name: strategy
description: Testing philosophy, patterns, and quality metrics. Covers the testing pyramid, test design patterns (AAA, BDD, fixtures, factories), edge case checklists, and debugging flaky tests.
---

# Testing Strategy

Core testing philosophy and patterns for building reliable, maintainable test suites.

## The Testing Pyramid

```
        /\
       /  \
      / E2E \       Few, slow, high-confidence
     /--------\
    /Integration\   Some, medium speed
   /--------------\
  /     Unit       \  Many, fast, focused
 /------------------\
```

## Good Tests Are (FIRST)

| Principle | Description |
|-----------|-------------|
| **Fast** | Tests should run quickly. Slow tests don't get run. |
| **Isolated** | Each test is independent. No shared state, no order dependencies. |
| **Repeatable** | Same result every time. No flakiness, no external dependencies. |
| **Self-Validating** | Clear pass/fail. No manual inspection needed. |
| **Timely** | Written close to the code. TDD when appropriate. |

## Quality Metrics

| Metric | Target | Notes |
|--------|--------|-------|
| Line Coverage | 80%+ | For business logic |
| Branch Coverage | 70%+ | For complex conditionals |
| Mutation Score | 60%+ | Measures test effectiveness |
| Test Execution Time | < 5min | For unit tests |
| Flaky Test Rate | < 1% | Zero tolerance goal |

## Test Design Patterns

### Arrange-Act-Assert (AAA)

```typescript
it('should calculate total with tax', () => {
  // Arrange
  const items = [{ price: 10, quantity: 2 }];
  const taxRate = 0.08;
  
  // Act
  const total = calculateTotal(items, taxRate);
  
  // Assert
  expect(total).toBe(21.6);
});
```

### Given-When-Then (BDD)

```typescript
describe('User login', () => {
  describe('given valid credentials', () => {
    describe('when user submits login form', () => {
      it('then they should be redirected to dashboard', async () => {
        // Test implementation
      });
    });
  });
});
```

### Test Fixtures

```typescript
// fixtures/users.ts
export const validUser = {
  email: 'test@example.com',
  password: 'SecurePass123!',
  name: 'Test User'
};

export const adminUser = {
  ...validUser,
  email: 'admin@example.com',
  role: 'admin'
};
```

### Factory Pattern

```typescript
// factories/user.ts
export function createUser(overrides = {}) {
  return {
    id: faker.datatype.uuid(),
    email: faker.internet.email(),
    name: faker.name.fullName(),
    createdAt: new Date(),
    ...overrides
  };
}

// In tests
const user = createUser({ role: 'admin' });
```

## Edge Cases Checklist

### Input Validation
- [ ] Empty string / null / undefined
- [ ] Whitespace-only strings
- [ ] Maximum length inputs
- [ ] Special characters / Unicode / emoji
- [ ] Negative numbers / Zero / Very large numbers
- [ ] Invalid date formats

### Collections
- [ ] Empty array/object
- [ ] Single item
- [ ] Many items (performance)
- [ ] Duplicate items
- [ ] Unsorted input

### Async Operations
- [ ] Success case
- [ ] Timeout
- [ ] Network error
- [ ] Partial failure
- [ ] Retry behavior

### Authentication/Authorization
- [ ] Unauthenticated access
- [ ] Invalid/expired token
- [ ] Insufficient permissions
- [ ] Cross-user data access

## Debugging Flaky Tests

### Common Causes & Fixes

| Cause | Bad | Good |
|-------|-----|------|
| Timing | `await sleep(1000)` | `await waitFor(() => expect(el).toBeVisible())` |
| Shared state | Global `let counter` | Reset in `beforeEach` |
| External deps | Real API calls | Mock or test containers |
| Order deps | Tests depend on order | Each test is independent |
| Date/time | `new Date()` | Mock the clock |

### Isolation Fix

```typescript
// Bad: Shared state
let counter = 0;
it('test 1', () => { counter++; });
it('test 2', () => { expect(counter).toBe(0); }); // Fails!

// Good: Reset in beforeEach
let counter: number;
beforeEach(() => { counter = 0; });
```

## Test Types Summary

| Type | Scope | Speed | When to Use |
|------|-------|-------|-------------|
| Unit | Single function/class | Fast | Business logic, utilities |
| Integration | Multiple components | Medium | API endpoints, DB operations |
| E2E | Full user workflow | Slow | Critical paths, smoke tests |

## Tools by Type

| Type | Tools |
|------|-------|
| Unit/Integration | Jest, Vitest, Testing Library |
| E2E/Browser | Playwright, agent-browser |
| API | Supertest, Postman/Newman |
| Mocking | MSW, jest.mock, vi.mock |
