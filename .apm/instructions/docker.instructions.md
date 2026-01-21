---
applyTo: "**/Dockerfile*"
description: "Docker best practices for secure, efficient, and maintainable container images"
---

# Docker Standards

## Multi-Stage Builds

### Basic Pattern

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20-alpine AS production
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Advanced Multi-Stage

```dockerfile
# Base stage with common dependencies
FROM node:20-alpine AS base
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Dependencies stage
FROM base AS deps
COPY package*.json ./
RUN npm ci --only=production && \
    cp -R node_modules prod_modules && \
    npm ci

# Build stage
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Test stage (optional, for CI)
FROM builder AS test
RUN npm run test

# Production stage
FROM base AS production
ENV NODE_ENV=production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 appuser

COPY --from=deps --chown=appuser:nodejs /app/prod_modules ./node_modules
COPY --from=builder --chown=appuser:nodejs /app/dist ./dist
COPY --chown=appuser:nodejs package*.json ./

USER appuser
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

## Base Image Selection

### Image Recommendations

| Use Case | Image | Size | Notes |
|----------|-------|------|-------|
| Node.js | `node:20-alpine` | ~50MB | Best for most cases |
| Node.js (distroless) | `gcr.io/distroless/nodejs20` | ~40MB | No shell, most secure |
| Python | `python:3.12-slim` | ~45MB | Good balance |
| Go | `scratch` or `gcr.io/distroless/static` | <5MB | Static binaries |
| Java | `eclipse-temurin:21-jre-alpine` | ~80MB | JRE only |
| General | `alpine:3.19` | ~5MB | Minimal Linux |

### Version Pinning

```dockerfile
# Bad - mutable tag
FROM node:latest
FROM node:20

# Good - specific version
FROM node:20.10.0-alpine3.19

# Better - SHA digest (immutable)
FROM node:20.10.0-alpine3.19@sha256:abc123...
```

## Layer Optimization

### Order for Cache Efficiency

```dockerfile
# Dependencies change less frequently - copy first
COPY package*.json ./
RUN npm ci

# Source changes frequently - copy last
COPY . .
RUN npm run build
```

### Minimize Layers

```dockerfile
# Bad - multiple RUN commands
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Good - combined and cleaned
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### Avoid Unnecessary Files

```dockerfile
# Use .dockerignore
# .dockerignore contents:
# node_modules
# .git
# .env*
# *.md
# Dockerfile*
# docker-compose*
# .github/
# coverage/
# test/
```

## Security

### Non-Root User

```dockerfile
# Create and use non-root user
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --ingroup appgroup appuser

# Change ownership of app files
COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser
```

### No Secrets in Images

```dockerfile
# Bad - secret in build arg
ARG DATABASE_PASSWORD
ENV DATABASE_PASSWORD=$DATABASE_PASSWORD

# Bad - secret in layer
COPY .env ./

# Good - secrets at runtime only
# Pass via docker run -e or secrets management
ENV DATABASE_HOST=db.example.com
# DATABASE_PASSWORD provided at runtime
```

### Minimal Attack Surface

```dockerfile
# Use distroless for production
FROM gcr.io/distroless/nodejs20-debian12
COPY --from=builder /app/dist /app
WORKDIR /app
CMD ["index.js"]

# Or use scratch for static binaries
FROM scratch
COPY --from=builder /app/myapp /myapp
ENTRYPOINT ["/myapp"]
```

### Security Scanning

```dockerfile
# Add labels for vulnerability tracking
LABEL org.opencontainers.image.source="https://github.com/org/repo"
LABEL org.opencontainers.image.revision="${GIT_SHA}"

# Scan with Trivy, Snyk, or Grype in CI
# trivy image myimage:latest
```

## ENTRYPOINT vs CMD

### Understanding the Difference

| Directive | Purpose | Override |
|-----------|---------|----------|
| `ENTRYPOINT` | Main executable | `--entrypoint` flag |
| `CMD` | Default arguments | Arguments after image name |

### Best Practices

```dockerfile
# For applications - use ENTRYPOINT
ENTRYPOINT ["node", "dist/index.js"]
CMD ["--port", "3000"]  # Default args, overridable

# For utilities - use CMD
CMD ["npm", "start"]  # Easily overridable

# Always use exec form (JSON array)
# Good
ENTRYPOINT ["node", "app.js"]

# Bad - runs in shell, breaks signal handling
ENTRYPOINT node app.js
```

### Init Process

```dockerfile
# Use tini for proper signal handling
RUN apk add --no-cache tini
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "dist/index.js"]

# Or use --init flag at runtime
# docker run --init myimage
```

## Health Checks

### Basic Health Check

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
```

### Health Check Patterns

```dockerfile
# HTTP endpoint
HEALTHCHECK CMD curl -f http://localhost:3000/health || exit 1

# Node.js without curl
HEALTHCHECK CMD node -e "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

# TCP port check
HEALTHCHECK CMD nc -z localhost 3000 || exit 1

# Custom script
COPY healthcheck.sh /healthcheck.sh
HEALTHCHECK CMD /healthcheck.sh
```

## Environment Configuration

### Build-Time vs Runtime

```dockerfile
# Build-time only (not in final image)
ARG NODE_ENV=production
ARG BUILD_VERSION

# Runtime environment
ENV NODE_ENV=production
ENV PORT=3000

# Use ARG in build, ENV at runtime
ARG APP_VERSION
ENV APP_VERSION=${APP_VERSION}
```

### Configuration Best Practices

```dockerfile
# Set sensible defaults
ENV NODE_ENV=production \
    PORT=3000 \
    LOG_LEVEL=info

# Document expected runtime variables
# Required at runtime:
#   DATABASE_URL - PostgreSQL connection string
#   API_KEY - External API key
```

## Caching Strategies

### Package Manager Caching

```dockerfile
# npm with cache mount
RUN --mount=type=cache,target=/root/.npm \
    npm ci

# pnpm with cache
RUN --mount=type=cache,target=/root/.local/share/pnpm/store \
    pnpm install --frozen-lockfile

# pip with cache
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt
```

### BuildKit Cache Mounts

```dockerfile
# syntax=docker/dockerfile:1.4

# Cache apt packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y curl

# Cache go modules
RUN --mount=type=cache,target=/go/pkg/mod \
    go build -o /app/main .
```

## Labels and Metadata

### OCI Standard Labels

```dockerfile
LABEL org.opencontainers.image.title="My Application"
LABEL org.opencontainers.image.description="Application description"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.vendor="My Company"
LABEL org.opencontainers.image.url="https://example.com"
LABEL org.opencontainers.image.source="https://github.com/org/repo"
LABEL org.opencontainers.image.revision="${GIT_SHA}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.licenses="MIT"
```

### Dynamic Labels in Build

```dockerfile
ARG GIT_SHA
ARG BUILD_DATE

LABEL org.opencontainers.image.revision="${GIT_SHA}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
```

```bash
# Build with args
docker build \
  --build-arg GIT_SHA=$(git rev-parse HEAD) \
  --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  -t myimage .
```

## Language-Specific Patterns

### Node.js

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Build
COPY . .
RUN npm run build && npm prune --production

FROM node:20-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app

COPY --from=builder --chown=app:app /app/dist ./dist
COPY --from=builder --chown=app:app /app/node_modules ./node_modules
COPY --chown=app:app package*.json ./

USER app
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Python

```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app

RUN pip install --no-cache-dir poetry
COPY pyproject.toml poetry.lock ./
RUN poetry export -f requirements.txt -o requirements.txt

FROM python:3.12-slim
WORKDIR /app

RUN useradd -r -s /bin/false app
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=app:app . .
USER app
CMD ["python", "-m", "myapp"]
```

### Go

```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/main .

FROM scratch
COPY --from=builder /app/main /main
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/main"]
```

## Anti-Patterns

### Avoid These Patterns

```dockerfile
# Bad: Running as root
FROM node:20
COPY . .
CMD ["node", "app.js"]

# Bad: Installing unnecessary tools
RUN apt-get install -y vim nano curl wget git

# Bad: Secrets in image
COPY .env ./
ENV API_KEY=secret123

# Bad: Not cleaning up in same layer
RUN apt-get update
RUN apt-get install -y curl
# Cache and lists remain in image

# Bad: Large context
# (missing .dockerignore, copying node_modules)
COPY . .

# Bad: Unpinned versions
FROM node:latest
RUN npm install express
```

### Preferred Patterns

```dockerfile
# Good: Non-root user
FROM node:20-alpine
RUN addgroup -S app && adduser -S app -G app
USER app

# Good: Minimal dependencies
RUN apk add --no-cache curl

# Good: No secrets in image
# Secrets passed at runtime via -e or secrets

# Good: Clean in same layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Good: Proper .dockerignore
# See .dockerignore section

# Good: Pinned versions
FROM node:20.10.0-alpine3.19
RUN npm ci  # Uses lockfile
```

## Docker Compose Integration

### Development Setup

```yaml
# docker-compose.yml
services:
  app:
    build:
      context: .
      target: development
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    ports:
      - "3000:3000"
```

### Multi-Stage in Compose

```yaml
services:
  app:
    build:
      context: .
      target: production
      args:
        - GIT_SHA=${GIT_SHA}
    image: myapp:${VERSION:-latest}
```

## Build Commands

### Basic Build

```bash
# Standard build
docker build -t myapp:latest .

# Build specific stage
docker build --target builder -t myapp:builder .

# Build with args
docker build --build-arg NODE_ENV=development -t myapp:dev .

# Build with BuildKit
DOCKER_BUILDKIT=1 docker build -t myapp .

# Build without cache
docker build --no-cache -t myapp .
```

### BuildKit Features

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build with inline cache
docker build --cache-from myapp:latest -t myapp:new .

# Export cache
docker build --cache-to type=local,dest=./cache -t myapp .

# Multi-platform build
docker buildx build --platform linux/amd64,linux/arm64 -t myapp .
```
