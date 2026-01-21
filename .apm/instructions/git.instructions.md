---
applyTo: "**/*"
description: "Git workflow standards for commits, branches, and pull requests"
---

# Git Standards

## Commit Messages

### Format
Follow the Conventional Commits specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types
| Type | Purpose |
|------|---------|
| `feat` | New feature for users |
| `fix` | Bug fix for users |
| `docs` | Documentation changes only |
| `style` | Formatting, no code change |
| `refactor` | Code change that neither fixes nor adds |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system or dependencies |
| `ci` | CI/CD configuration |
| `chore` | Maintenance tasks |
| `revert` | Revert a previous commit |

### Scope
The scope is optional but recommended. Use the module, component, or area affected:

```
feat(auth): add OAuth2 login support
fix(cart): resolve quantity update race condition
docs(api): update authentication examples
refactor(users): extract validation logic to service
```

### Description Rules
- Use imperative mood: "add" not "added" or "adds"
- Don't capitalize first letter
- No period at the end
- Maximum 72 characters

```
# Good
feat(search): add fuzzy matching support

# Bad
feat(search): Added fuzzy matching support.
```

### Body
- Separate from subject with a blank line
- Explain *what* and *why*, not *how*
- Wrap at 72 characters

```
fix(payments): handle declined card gracefully

Previously, a declined card would cause an unhandled exception
that crashed the checkout flow. Users had to restart the entire
purchase process.

Now we catch the PaymentDeclinedError and show a friendly message
asking the user to try a different payment method.
```

### Breaking Changes
Use `BREAKING CHANGE:` in the footer or `!` after type:

```
feat(api)!: change authentication to Bearer tokens

BREAKING CHANGE: API now requires Bearer token authentication.
Basic auth is no longer supported. See migration guide at
docs/auth-migration.md.
```

## Branch Naming

### Format
```
<type>/<ticket-id>-<short-description>
```

### Types
| Prefix | Purpose |
|--------|---------|
| `feature/` | New features |
| `fix/` | Bug fixes |
| `hotfix/` | Urgent production fixes |
| `refactor/` | Code refactoring |
| `docs/` | Documentation |
| `test/` | Test additions/updates |
| `chore/` | Maintenance |

### Examples
```
feature/AUTH-123-oauth-login
fix/CART-456-quantity-validation
hotfix/PAY-789-stripe-timeout
refactor/USER-012-extract-validation
docs/API-345-auth-examples
```

### Rules
- Use lowercase
- Use hyphens to separate words
- Include ticket ID if applicable
- Keep description brief (2-4 words)

## Pull Requests

### Title Format
Same as commit message format:
```
feat(auth): add OAuth2 login support
```

### Description Template
```markdown
## Summary
Brief description of changes and motivation.

## Changes
- Added OAuth2 login flow
- Updated user session handling
- Added tests for token refresh

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots
(If UI changes)

## Related
- Closes #123
- Related to #456
```

### Review Guidelines
- Keep PRs focused and small (< 400 lines when possible)
- Self-review before requesting others
- Respond to feedback within 24 hours
- Use "Request changes" sparingly, prefer suggestions

## Workflow

### Feature Development
```bash
# Start from up-to-date main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/AUTH-123-oauth-login

# Make commits (atomic, logical units)
git add .
git commit -m "feat(auth): add OAuth provider configuration"

git add .
git commit -m "feat(auth): implement OAuth callback handler"

git add .
git commit -m "test(auth): add OAuth flow tests"

# Push and create PR
git push -u origin feature/AUTH-123-oauth-login
```

### Keeping Branch Updated
```bash
# Rebase on main for clean history (preferred)
git fetch origin
git rebase origin/main

# Or merge if rebase is problematic
git fetch origin
git merge origin/main
```

### Handling Review Feedback
```bash
# Make requested changes
git add .
git commit -m "fix(auth): address review feedback - validate state param"

# Push updates
git push
```

### Squash Strategy
- Squash commits when merging if the PR has many "fix" or "wip" commits
- Keep separate commits if each represents a logical, reviewable unit

## Gitignore

### Always Ignore
```gitignore
# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
.next/
.astro/

# Environment
.env
.env.local
.env.*.local

# IDE
.idea/
.vscode/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Test coverage
coverage/
.nyc_output/
```

### Never Commit
- API keys or secrets
- Personal configuration
- Generated files that can be rebuilt
- Large binary files (use Git LFS)
