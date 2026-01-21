---
applyTo: "**/*.{ts,tsx}"
description: "TypeScript coding standards with strict type safety and modern best practices"
---

# TypeScript Standards

## Type Safety

### Strict Mode Required
- Enable `"strict": true` in tsconfig.json
- Never disable strict checks with `@ts-ignore` or `@ts-expect-error` without a documented reason

### No `any` Type
- Use `unknown` when the type is truly uncertain, then narrow with type guards
- Use generics for flexible but type-safe functions
- Use `Record<string, unknown>` instead of `object` or `{}`

```typescript
// Bad
function parse(data: any): any { ... }

// Good
function parse<T>(data: unknown): T {
  // Validate and narrow the type
}
```

### Explicit Return Types
- All exported functions must have explicit return types
- Internal functions may use inference if the return is obvious
- Async functions should return `Promise<T>` explicitly

```typescript
// Required for exports
export function calculateTotal(items: Item[]): number { ... }
export async function fetchUser(id: string): Promise<User> { ... }
```

## Interfaces vs Types

### Prefer Interfaces for Objects
- Use `interface` for object shapes that may be extended
- Use `type` for unions, intersections, and computed types

```typescript
// Object shapes
interface User {
  id: string;
  name: string;
  email: string;
}

// Unions and computed types
type Status = 'pending' | 'active' | 'archived';
type UserWithStatus = User & { status: Status };
```

### Naming Conventions
- Interfaces: PascalCase, noun-based (`User`, `ApiResponse`)
- Types: PascalCase (`StatusType`, `ConfigOptions`)
- No `I` prefix for interfaces
- No `T` prefix for types (except generic parameters)

## Functions

### Parameter Handling
- Use destructuring for objects with 3+ properties
- Provide default values where sensible
- Use readonly for parameters that shouldn't be mutated

```typescript
// Destructure complex parameters
function createUser({
  name,
  email,
  role = 'user',
}: {
  name: string;
  email: string;
  role?: UserRole;
}): User { ... }

// Mark readonly to prevent mutation
function processItems(items: readonly Item[]): Result { ... }
```

### Error Handling
- Use typed error classes or discriminated unions
- Never throw plain strings
- Document thrown errors in JSDoc

```typescript
class ValidationError extends Error {
  constructor(
    message: string,
    public readonly field: string,
    public readonly code: string,
  ) {
    super(message);
    this.name = 'ValidationError';
  }
}
```

## Null Safety

### Prefer Undefined Over Null
- Use `undefined` for optional values
- Use `null` only for intentional "no value" semantics (e.g., database fields)

### Nullish Coalescing and Optional Chaining
- Use `??` instead of `||` for default values
- Use `?.` for optional property access

```typescript
// Correct null handling
const name = user?.profile?.name ?? 'Anonymous';
const count = config.limit ?? 10; // 0 is a valid value, don't use ||
```

## Imports and Exports

### Import Organization
1. External packages (node_modules)
2. Internal aliases (@/...)
3. Relative imports (./...)

### Named Exports Preferred
- Use named exports for most cases
- Default exports only for React components and page routes

```typescript
// Preferred
export { UserService, UserRepository };

// Only for components/pages
export default function UserProfile() { ... }
```

## Async Patterns

### Promise Handling
- Always handle promise rejections
- Prefer async/await over .then() chains
- Use Promise.all() for parallel operations

```typescript
// Parallel operations
const [users, posts] = await Promise.all([
  fetchUsers(),
  fetchPosts(),
]);

// Sequential with proper error handling
try {
  const user = await fetchUser(id);
  const profile = await fetchProfile(user.profileId);
} catch (error) {
  if (error instanceof NotFoundError) {
    // Handle specific error
  }
  throw error;
}
```

## Documentation

### JSDoc for Public APIs
- Document all exported functions, classes, and interfaces
- Include `@param`, `@returns`, `@throws`, and `@example` where applicable

```typescript
/**
 * Calculates the total price including tax.
 *
 * @param items - Array of items with price and quantity
 * @param taxRate - Tax rate as a decimal (e.g., 0.08 for 8%)
 * @returns Total price with tax applied
 * @throws {ValidationError} If items array is empty
 *
 * @example
 * const total = calculateTotal([{ price: 10, quantity: 2 }], 0.08);
 * // Returns 21.6
 */
export function calculateTotal(items: Item[], taxRate: number): number { ... }
```
