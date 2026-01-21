---
name: containers
description: Docker best practices for secure, efficient container images. Covers multi-stage builds, base image selection, layer optimization, security hardening, and health checks.
---

# Container Patterns

Docker best practices for building secure, efficient, and maintainable container images.

## Multi-Stage Builds

```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=builder --chown=app:app /app/dist ./dist
COPY --from=builder --chown=app:app /app/node_modules ./node_modules
USER app
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

## Base Image Selection

| Use Case | Image | Size |
|----------|-------|------|
| Node.js | `node:20-alpine` | ~50MB |
| Distroless Node | `gcr.io/distroless/nodejs20` | ~40MB |
| Python | `python:3.12-slim` | ~45MB |
| Go | `scratch` | <5MB |
| General | `alpine:3.19` | ~5MB |

### Version Pinning

```dockerfile
# Bad - mutable
FROM node:latest
FROM node:20

# Good - specific
FROM node:20.10.0-alpine3.19

# Best - immutable SHA
FROM node:20.10.0-alpine3.19@sha256:abc123...
```

## Layer Optimization

### Order for Cache Efficiency

```dockerfile
# Dependencies first (change less often)
COPY package*.json ./
RUN npm ci

# Source last (changes often)
COPY . .
RUN npm run build
```

### Minimize Layers

```dockerfile
# Bad
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get clean

# Good - combined and cleaned
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
```

## Security

### Non-Root User (Required)

```dockerfile
RUN addgroup -S app && adduser -S app -G app
COPY --chown=app:app . .
USER app
```

### No Secrets in Images

```dockerfile
# Bad
COPY .env ./
ENV API_KEY=secret123

# Good - runtime injection
# Pass via: docker run -e API_KEY=... or secrets manager
```

### Minimal Attack Surface

```dockerfile
# Use distroless (no shell)
FROM gcr.io/distroless/nodejs20
COPY --from=builder /app/dist /app
CMD ["index.js"]
```

## Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD wget --spider http://localhost:3000/health || exit 1
```

## ENTRYPOINT vs CMD

```dockerfile
# Application - use ENTRYPOINT
ENTRYPOINT ["node", "dist/index.js"]
CMD ["--port", "3000"]  # Default args

# Utility - use CMD (easily overridable)
CMD ["npm", "start"]

# Always use exec form (JSON array)
ENTRYPOINT ["node", "app.js"]  # Good
ENTRYPOINT node app.js          # Bad - shell form
```

## .dockerignore

```
node_modules
.git
.env*
*.md
Dockerfile*
docker-compose*
coverage/
test/
```

## BuildKit Features

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Cache mounts
RUN --mount=type=cache,target=/root/.npm npm ci

# Multi-platform
docker buildx build --platform linux/amd64,linux/arm64 -t myapp .
```

## Anti-Patterns

| Bad | Good |
|-----|------|
| Running as root | Non-root user |
| Installing vim/nano | Minimal dependencies |
| Secrets in image | Runtime injection |
| `FROM node:latest` | Pinned versions |
| No .dockerignore | Proper ignore file |

## Language Patterns

### Node.js

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm prune --production

FROM node:20-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=builder --chown=app:app /app/dist ./dist
COPY --from=builder --chown=app:app /app/node_modules ./node_modules
USER app
CMD ["node", "dist/index.js"]
```

### Go (Scratch)

```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /main .

FROM scratch
COPY --from=builder /main /main
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/main"]
```

> **Full Reference**: See `.apm/instructions/docker.instructions.md` for complete details.
