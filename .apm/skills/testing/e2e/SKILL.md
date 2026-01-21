---
name: e2e
description: End-to-end browser testing patterns using Playwright and agent-browser CLI. Covers E2E test structure, user workflow testing, and AI-friendly browser automation.
---

# E2E Testing

End-to-end testing patterns for complete user workflow verification.

## When to Use E2E Tests

- Critical user paths (login, checkout, signup)
- Smoke tests for deployment verification
- Cross-browser compatibility testing
- Full integration with external services

## E2E Test Structure

```typescript
test('complete checkout flow', async ({ page }) => {
  // Login
  await page.goto('/login');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'password123');
  await page.click('button[type="submit"]');
  
  // Add to cart
  await page.goto('/products/1');
  await page.click('button:has-text("Add to Cart")');
  
  // Checkout
  await page.goto('/checkout');
  await page.fill('[name="card"]', '4242424242424242');
  await page.click('button:has-text("Pay")');
  
  // Verify
  await expect(page).toHaveURL(/\/orders\/\d+/);
  await expect(page.locator('.order-status')).toHaveText('Confirmed');
});
```

## Playwright Best Practices

### Page Object Model

```typescript
// pages/login.page.ts
export class LoginPage {
  constructor(private page: Page) {}
  
  async goto() {
    await this.page.goto('/login');
  }
  
  async login(email: string, password: string) {
    await this.page.fill('[name="email"]', email);
    await this.page.fill('[name="password"]', password);
    await this.page.click('button[type="submit"]');
  }
}

// In test
const loginPage = new LoginPage(page);
await loginPage.goto();
await loginPage.login('user@example.com', 'password');
```

### Reliable Selectors (Priority Order)

1. `data-testid="submit-btn"` - Most stable
2. `role` attributes - `getByRole('button', { name: 'Submit' })`
3. Text content - `getByText('Submit')`
4. CSS selectors - Last resort

### Waiting Strategies

```typescript
// Good: Wait for specific condition
await page.waitForSelector('.loaded');
await expect(page.locator('.result')).toBeVisible();

// Bad: Fixed delays
await page.waitForTimeout(2000); // Avoid!
```

## agent-browser CLI

AI-friendly browser automation from `vercel-labs/agent-browser` APM dependency.

### Core Workflow

```bash
# 1. Navigate
agent-browser open https://example.com

# 2. Snapshot (get interactive elements with refs)
agent-browser snapshot -i
# Output: @e1 [button] "Sign In"
#         @e2 [input:email] placeholder="Email"
#         @e3 [input:password] placeholder="Password"

# 3. Interact using refs
agent-browser fill @e2 "user@example.com"
agent-browser fill @e3 "password123"
agent-browser click @e1

# 4. Re-snapshot after page changes
agent-browser snapshot -i

# 5. Close when done
agent-browser close
```

### Key Commands

| Command | Description |
|---------|-------------|
| `open <url>` | Navigate to URL |
| `snapshot` | Get page state (text content) |
| `snapshot -i` | Get interactive elements with refs |
| `click @ref` | Click element by ref |
| `fill @ref "text"` | Fill input by ref |
| `select @ref "value"` | Select dropdown option |
| `scroll up/down` | Scroll the page |
| `close` | Close browser |

### Why agent-browser?

- **AI-friendly**: Refs (@e1, @e2) for deterministic element selection
- **Minimal context**: Concise output, no large DOM dumps
- **Zero config**: Single CLI install, headless by default
- **Sessions**: `--session name` for parallel isolated browsers

### Session Management

```bash
# Run tests in parallel with isolated sessions
agent-browser open https://app.com --session test1
agent-browser open https://app.com --session test2

# Each session has its own browser instance
agent-browser click @e1 --session test1
agent-browser click @e2 --session test2
```

## E2E Testing Checklist

### Before Writing Tests
- [ ] Identify critical user paths
- [ ] Set up test data/fixtures
- [ ] Configure test environment

### Test Quality
- [ ] Tests are independent (no order dependencies)
- [ ] Use proper waits (no fixed delays)
- [ ] Stable selectors (data-testid preferred)
- [ ] Clear assertions with meaningful messages
- [ ] Clean up test data after runs

### CI Integration
- [ ] Run in headless mode
- [ ] Capture screenshots on failure
- [ ] Parallelize where possible
- [ ] Set reasonable timeouts
