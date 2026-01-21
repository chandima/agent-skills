---
name: security
description: Security review patterns covering secrets, input validation, authentication, authorization, and common vulnerabilities. Use when reviewing code for security issues or implementing secure features.
---

# Security Review

Security-focused code review patterns to identify and prevent common vulnerabilities.

## Security Checklist

### Secrets Management
- [ ] No hardcoded secrets or credentials
- [ ] No secrets in comments or documentation
- [ ] No secrets in error messages or logs
- [ ] Environment variables used for configuration
- [ ] `.env` files excluded from version control

### Input Validation
- [ ] All user input validated server-side
- [ ] SQL queries are parameterized
- [ ] Output is properly escaped (XSS prevention)
- [ ] File uploads validated and sanitized
- [ ] Allowlists preferred over denylists

### Authentication
- [ ] Passwords hashed with bcrypt/Argon2/scrypt
- [ ] Rate limiting on login attempts
- [ ] Secure session management (httpOnly, secure cookies)
- [ ] Session invalidation on logout
- [ ] JWT secrets are strong and from environment

### Authorization
- [ ] Authorization checked on every request
- [ ] No client-side only authorization
- [ ] Resource ownership verified (IDOR prevention)
- [ ] Principle of least privilege applied

### Error Handling
- [ ] Generic error messages for users
- [ ] Detailed errors logged server-side only
- [ ] No stack traces in production responses

## Common Vulnerabilities

### SQL Injection

```typescript
// NEVER do this
const query = `SELECT * FROM users WHERE email = '${email}'`;

// Use parameterized queries
const user = await db.query(
  'SELECT * FROM users WHERE email = $1',
  [email]
);

// Or use an ORM
const user = await prisma.user.findUnique({
  where: { email },
});
```

### XSS Prevention

```typescript
// React automatically escapes - safe
function UserName({ name }: { name: string }) {
  return <span>{name}</span>;
}

// Dangerous - avoid unless absolutely necessary
function RawHtml({ html }: { html: string }) {
  return <div dangerouslySetInnerHTML={{ __html: html }} />; // XSS risk!
}
```

### Password Handling

```typescript
import bcrypt from 'bcrypt';

const SALT_ROUNDS = 12;

async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, SALT_ROUNDS);
}

async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

### Session Configuration

```typescript
const sessionConfig = {
  secret: process.env.SESSION_SECRET,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict' as const,
    maxAge: 24 * 60 * 60 * 1000, // 24 hours
  },
};
```

### Environment Validation

```typescript
function validateEnv() {
  const required = ['DATABASE_URL', 'API_KEY', 'JWT_SECRET'];
  const missing = required.filter((key) => !process.env[key]);
  
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }
}
```

### Authorization Check

```typescript
async function getDocument(userId: string, documentId: string) {
  const document = await db.document.findUnique({
    where: { id: documentId },
  });
  
  if (!document) {
    throw new NotFoundError('Document not found');
  }
  
  // Always verify ownership/access
  if (document.ownerId !== userId && !document.sharedWith.includes(userId)) {
    throw new ForbiddenError('Access denied');
  }
  
  return document;
}
```

### Safe Logging

```typescript
// Safe logging
logger.info('User login', {
  userId: user.id,
  success: true,
  ip: request.ip,
});

// NEVER log these
// password, creditCard, sessionToken, apiKey
```

## HTTP Security Headers

```typescript
const securityHeaders = {
  'Content-Security-Policy': "default-src 'self'",
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-XSS-Protection': '1; mode=block',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
};
```

## Dependency Security

```bash
# Check for vulnerabilities
npm audit

# Fix automatically where possible
npm audit fix

# Update to latest security patches
npm update
```

Review packages before adding:
- Check maintenance status
- Review download counts
- Audit permissions requested
