---
applyTo: "**/*.{ts,tsx,js,jsx,py,java,go,rs,rb,php,cs,cpp,c,h,hpp}"
description: "Security guardrails for AI-assisted development to prevent common vulnerabilities"
---

# Security Standards

## Secrets Management

### Never Commit Secrets
- No API keys, tokens, or passwords in code
- No secrets in comments or documentation
- No secrets in error messages or logs

```typescript
// NEVER do this
const API_KEY = "sk-1234567890abcdef";
const DB_PASSWORD = "supersecret123";

// Use environment variables
const API_KEY = process.env.API_KEY;
const DB_PASSWORD = process.env.DB_PASSWORD;
```

### Environment Variables
- Use `.env` files for local development (never commit)
- Use secrets management for production (Vault, AWS Secrets Manager, etc.)
- Validate required env vars at startup

```typescript
function validateEnv() {
  const required = ['DATABASE_URL', 'API_KEY', 'JWT_SECRET'];
  const missing = required.filter((key) => !process.env[key]);
  
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }
}
```

## Input Validation

### Never Trust User Input
- Validate all input on the server side
- Sanitize data before storage or display
- Use allowlists over denylists

```typescript
// Validate with a schema
import { z } from 'zod';

const UserInput = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().positive().max(150),
});

function createUser(input: unknown) {
  const validated = UserInput.parse(input);
  // Now safe to use
}
```

### SQL Injection Prevention
- Always use parameterized queries
- Never concatenate user input into queries
- Use ORM/query builders with proper escaping

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
- Escape all user-generated content before rendering
- Use framework-provided escaping (React, Vue auto-escape)
- Set Content-Security-Policy headers

```typescript
// React automatically escapes
function UserName({ name }: { name: string }) {
  return <span>{name}</span>; // Safe
}

// Dangerous - avoid unless absolutely necessary
function RawHtml({ html }: { html: string }) {
  return <div dangerouslySetInnerHTML={{ __html: html }} />; // XSS risk!
}
```

## Authentication

### Password Handling
- Never store plaintext passwords
- Use bcrypt, Argon2, or scrypt with appropriate cost factors
- Implement rate limiting on login attempts

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

### Session Management
- Use secure, httpOnly cookies
- Implement session expiration
- Regenerate session ID after login
- Invalidate sessions on logout

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

### JWT Best Practices
- Use strong secrets (minimum 256 bits)
- Set appropriate expiration times
- Validate all claims on every request
- Use refresh tokens for long sessions

```typescript
const tokenConfig = {
  accessTokenExpiry: '15m',
  refreshTokenExpiry: '7d',
  algorithm: 'HS256' as const,
};
```

## Authorization

### Principle of Least Privilege
- Grant minimum necessary permissions
- Check authorization on every request
- Never rely on client-side authorization alone

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

### IDOR Prevention
- Never expose internal IDs directly
- Use UUIDs instead of sequential IDs
- Always verify resource ownership

## Error Handling

### Don't Leak Information
- Use generic error messages for users
- Log detailed errors server-side only
- Never expose stack traces in production

```typescript
try {
  await processPayment(order);
} catch (error) {
  // Log detailed error for debugging
  logger.error('Payment failed', {
    orderId: order.id,
    error: error.message,
    stack: error.stack,
  });
  
  // Return generic message to user
  throw new PaymentError('Payment processing failed. Please try again.');
}
```

## Dependencies

### Security Auditing
- Run `npm audit` or equivalent regularly
- Update dependencies promptly for security patches
- Pin dependency versions in production

```bash
# Check for vulnerabilities
npm audit

# Fix automatically where possible
npm audit fix

# Update to latest security patches
npm update
```

### Dependency Review
- Evaluate packages before adding
- Check maintenance status and download counts
- Review permissions requested

## HTTP Security Headers

### Required Headers
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

## Logging

### What to Log
- Authentication attempts (success and failure)
- Authorization failures
- Input validation failures
- Security-relevant configuration changes

### What Not to Log
- Passwords (even hashed)
- Full credit card numbers
- Personal identification numbers
- Session tokens or API keys

```typescript
// Safe logging
logger.info('User login', {
  userId: user.id,
  email: user.email, // Consider if PII logging is required
  success: true,
  ip: request.ip,
});

// Never log this
logger.info('Login attempt', {
  password: password, // NEVER
  creditCard: cardNumber, // NEVER
  sessionToken: token, // NEVER
});
```
