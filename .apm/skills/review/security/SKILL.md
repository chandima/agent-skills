---
name: security
description: Security vulnerability detection methodology. Use when reviewing code to find security issues - focuses on HOW TO FIND vulnerabilities, not how to write secure code.
---

# Security Review Methodology

This skill teaches you HOW TO FIND security vulnerabilities during code review. For HOW TO WRITE secure code, see `.apm/instructions/security.instructions.md`.

## Detection Approach

### 1. Secrets Detection

**What to look for:**
- Hardcoded strings that look like API keys, tokens, passwords
- Configuration values that should be environment variables
- Comments containing credentials ("password is xyz")

**Search patterns:**
```bash
# Find potential hardcoded secrets
grep -rE "(api[_-]?key|password|secret|token|credential)\s*[:=]" --include="*.{ts,js,py,java,go}"
grep -rE "sk-[a-zA-Z0-9]{20,}" --include="*.{ts,js,py}"  # OpenAI-style keys
grep -rE "ghp_[a-zA-Z0-9]{36}" --include="*.{ts,js,py}"  # GitHub PATs
grep -rE "AKIA[0-9A-Z]{16}" --include="*.{ts,js,py}"     # AWS access keys
```

**Red flags:**
- Strings longer than 20 characters in configuration
- Base64-encoded values in source code
- `.env` files committed to repo
- Secrets in error messages or logs

---

### 2. SQL Injection Detection

**What to look for:**
- String concatenation or template literals in database queries
- Dynamic column/table names from user input
- Raw query methods without parameterization

**Search patterns:**
```bash
# Find string concatenation in queries
grep -rE "SELECT.*\+" --include="*.{ts,js,py,java}"
grep -rE "SELECT.*\\\$\{" --include="*.{ts,js}"          # Template literals
grep -rE "query\s*\(\s*[\"'].*\+" --include="*.{ts,js}"  # query('...' + 
grep -rE "execute\s*\(\s*f[\"']" --include="*.py"        # Python f-strings
```

**Red flags:**
- `query("SELECT * FROM " + table)`
- `` query(`SELECT * FROM ${table}`) ``
- `ORDER BY` with dynamic column names
- `WHERE IN (${ids.join(',')})` without sanitization

---

### 3. XSS Detection

**What to look for:**
- User input rendered as HTML without escaping
- Direct DOM manipulation with user data
- Framework escape hatches being used

**Search patterns:**
```bash
# Find dangerous patterns
grep -rE "dangerouslySetInnerHTML" --include="*.{tsx,jsx}"
grep -rE "v-html" --include="*.vue"
grep -rE "innerHTML\s*=" --include="*.{ts,js}"
grep -rE "\[innerHTML\]" --include="*.{html,ts}"          # Angular
grep -rE "\|.*safe" --include="*.html"                    # Django/Jinja safe filter
```

**Red flags:**
- `dangerouslySetInnerHTML` with user-provided content
- `element.innerHTML = userInput`
- Marked/rendered markdown from untrusted sources
- HTML email templates with user data

---

### 4. Authentication Issues

**What to look for:**
- Missing authentication on endpoints
- Weak password handling
- Session management issues

**Search patterns:**
```bash
# Find auth-related code
grep -rE "@(Public|NoAuth|AllowAnonymous)" --include="*.{ts,java,cs}"
grep -rE "password.*==" --include="*.{ts,js,py}"          # Weak comparison
grep -rE "md5|sha1" --include="*.{ts,js,py}"              # Weak hashing
grep -rE "cookie.*secure.*false" --include="*.{ts,js}"
```

**Red flags:**
- Comparing passwords with `==` instead of timing-safe comparison
- Using MD5/SHA1 for password hashing
- Missing `httpOnly` or `secure` on session cookies
- JWT tokens without expiration
- No rate limiting on login endpoints

---

### 5. Authorization (IDOR) Detection

**What to look for:**
- Resource access without ownership check
- Sequential/predictable IDs in URLs
- Missing authorization middleware

**Search patterns:**
```bash
# Find resource lookups without ownership check
grep -rE "findById|findUnique|findOne" --include="*.{ts,js}"
# Then verify these have ownership checks nearby
```

**Red flags:**
- `GET /users/:id` returns any user's data
- `DELETE /documents/:id` without checking document.ownerId
- APIs that accept user IDs in request body
- No tenant isolation in multi-tenant apps

**Review checklist:**
1. Find all routes with ID parameters
2. Check if ownership is verified after fetching resource
3. Verify authorization happens before any mutation

---

### 6. Error Handling Issues

**What to look for:**
- Stack traces in API responses
- Detailed error messages to users
- Logging sensitive data

**Search patterns:**
```bash
# Find error exposure patterns
grep -rE "catch.*res\.(json|send).*error" --include="*.{ts,js}"
grep -rE "catch.*return.*error\.message" --include="*.{ts,js}"
grep -rE "logger\.(info|log).*password" --include="*.{ts,js}"
```

**Red flags:**
- `catch (e) { res.json({ error: e.message, stack: e.stack }) }`
- Database errors exposed to client
- Logging request bodies that might contain passwords

---

### 7. Dependency Vulnerabilities

**What to look for:**
- Outdated packages with known CVEs
- Unused dependencies that increase attack surface
- Missing lockfiles

**Commands to run:**
```bash
npm audit                    # Node.js
pip-audit                    # Python  
safety check                 # Python alternative
snyk test                    # Multi-language
```

**Red flags:**
- No `package-lock.json` or equivalent
- Dependencies not updated in 6+ months
- Using deprecated packages

---

## Review Workflow

### Quick Security Scan
1. Run secret detection patterns
2. Search for dangerous function usage (innerHTML, dangerouslySetInnerHTML, etc.)
3. Run `npm audit` or equivalent
4. Check for missing auth decorators on new endpoints

### Deep Security Review
1. Map all input points (APIs, forms, file uploads)
2. Trace each input through the codebase
3. Verify validation at every boundary
4. Check authorization on every resource access
5. Review error handling for information leakage
6. Verify secrets management approach

---

## Output Format

When reporting security issues:

```markdown
## Security Issues Found

### CRITICAL: [Issue Type]
**Location**: `file.ts:42`
**Issue**: [What's wrong]
**Impact**: [What could happen]
**Detection**: [How you found it]
**Fix**: [How to resolve]

### HIGH: [Issue Type]
...
```

---

> **Reference**: For secure coding patterns and examples, see `.apm/instructions/security.instructions.md`
