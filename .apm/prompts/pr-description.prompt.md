---
description: "Generate comprehensive PR descriptions from staged changes"
---

# PR Description Generator

Generate a clear, comprehensive pull request description based on the changes in this branch.

## Parameters
- `base` (optional): Base branch to compare against (default: main)
- `style` (optional): Description style - concise, detailed, or changelog
- `include_testing` (optional): Include testing instructions (default: true)

## Process

### 1. Analyze Changes
Examine the changes to understand:
- What files were modified, added, or deleted
- The nature of each change (feature, fix, refactor, etc.)
- The scope and impact of changes

### 2. Identify Key Information
Determine:
- **What**: What was changed
- **Why**: The motivation or problem being solved
- **How**: The approach taken (if non-obvious)
- **Impact**: What areas of the codebase are affected

### 3. Generate Description
Create a PR description following the template below.

## Output Template

```markdown
## Summary

[1-2 sentence summary of what this PR accomplishes and why]

## Changes

### [Category 1: e.g., Features, Fixes, Refactoring]
- [Change 1 with brief explanation]
- [Change 2 with brief explanation]

### [Category 2: if applicable]
- [Change 1]
- [Change 2]

## Technical Details

[Optional: Explain any complex implementation decisions, algorithms, or architectural choices that reviewers should understand]

## Testing

### Automated Tests
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] All existing tests pass

### Manual Testing
[Instructions for manually testing the changes]

1. [Step 1]
2. [Step 2]
3. [Expected result]

## Screenshots

[If UI changes, include before/after screenshots]

## Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated (if needed)
- [ ] No breaking changes (or documented in migration notes)

## Related

- Closes #[issue-number]
- Related to #[issue-number]
- Depends on #[pr-number]
```

## Style Variations

### Concise Style
Use for small, straightforward changes:

```markdown
## Summary
Add email validation to user registration form.

## Changes
- Added email format validation using zod schema
- Added error message display for invalid emails
- Added unit tests for validation logic

## Testing
- Submit registration form with invalid email - should show error
- Submit with valid email - should proceed normally
```

### Detailed Style
Use for complex changes requiring more context:

```markdown
## Summary
Implement OAuth2 authentication flow with support for Google and GitHub providers.

## Motivation
Users have requested social login options to simplify the registration process. This reduces friction and improves conversion rates based on our user research.

## Changes

### Authentication
- Added OAuth2 provider configuration system
- Implemented callback handlers for Google and GitHub
- Added token exchange and session creation logic

### Database
- Added `oauth_accounts` table to link providers to users
- Added migration for new table structure

### UI
- Added social login buttons to login/register pages
- Added account linking UI in user settings

## Technical Details

### Provider Configuration
OAuth providers are configured via environment variables:
- `OAUTH_GOOGLE_CLIENT_ID` / `OAUTH_GOOGLE_CLIENT_SECRET`
- `OAUTH_GITHUB_CLIENT_ID` / `OAUTH_GITHUB_CLIENT_SECRET`

### Token Handling
Access tokens are not stored. We only keep the provider's user ID for account linking. Refresh tokens are encrypted at rest using AES-256.

## Testing
...
```

### Changelog Style
Use for release-oriented PRs:

```markdown
## v2.1.0

### Added
- OAuth2 authentication with Google and GitHub
- User settings page for account management
- Email notification preferences

### Changed
- Improved login page layout and accessibility
- Updated password requirements to 12 characters minimum

### Fixed
- Fixed race condition in cart quantity updates (#234)
- Fixed timezone handling in event scheduling (#256)

### Security
- Updated dependencies to address CVE-2024-1234
```

## Example Usage

```bash
# Generate description for current changes
/pr-description

# Compare against specific branch
/pr-description --param base="develop"

# Generate concise description
/pr-description --param style="concise"

# Exclude testing section
/pr-description --param include_testing="false"
```
