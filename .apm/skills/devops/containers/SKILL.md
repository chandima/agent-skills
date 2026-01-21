---
name: containers
description: Dockerfile audit methodology. Use when reviewing Docker images for security, efficiency, and best practices. Focuses on HOW TO AUDIT containers, not how to write Dockerfiles.
---

# Dockerfile Audit Methodology

This skill teaches you HOW TO AUDIT Dockerfiles and container images. For HOW TO WRITE Dockerfiles, see `.apm/instructions/docker.instructions.md`.

## Audit Approach

### 1. Security Audit

#### Running as Root

**What to look for:**
- Missing `USER` instruction
- `USER root` without switching back
- Files with incorrect ownership

**Detection patterns:**
```bash
# Find Dockerfiles without USER instruction
grep -L "^USER " Dockerfile*

# Find USER root without subsequent non-root USER
grep -n "USER" Dockerfile* | head

# Check if final USER is root
tail -20 Dockerfile | grep -E "^USER"
```

**Red flags:**
- No `USER` instruction anywhere (runs as root)
- `USER root` is the last USER instruction
- Missing `--chown` on COPY commands
- `chmod 777` anywhere in Dockerfile

#### Secrets in Image

**What to look for:**
- ARG/ENV with secret values
- COPY of .env or credential files
- Secrets in build commands

**Detection patterns:**
```bash
# Find potential secrets in Dockerfile
grep -iE "(password|secret|key|token|credential)" Dockerfile*
grep -E "^(ARG|ENV).*(PASSWORD|SECRET|KEY|TOKEN)" Dockerfile*
grep -E "^COPY.*\.env" Dockerfile*
grep -E "^COPY.*(credentials|secrets)" Dockerfile*

# Check for secrets in image layers
docker history --no-trunc <image> | grep -iE "(password|secret|key)"
```

**Red flags:**
- `ARG DATABASE_PASSWORD=...`
- `ENV API_KEY=sk-...`
- `COPY .env ./`
- `RUN curl -H "Authorization: Bearer $SECRET"`

#### Base Image Issues

**What to look for:**
- Unpinned base images
- Using `latest` tag
- Outdated or vulnerable base images

**Detection patterns:**
```bash
# Find unpinned or latest base images
grep -E "^FROM.*:latest" Dockerfile*
grep -E "^FROM [^:]+$" Dockerfile*        # No tag at all
grep -E "^FROM.*:[0-9]+$" Dockerfile*     # Major version only (e.g., node:20)

# Find missing SHA pinning
grep -E "^FROM" Dockerfile* | grep -v "@sha256"
```

**Red flags:**
- `FROM node:latest`
- `FROM python:3` (no minor version)
- `FROM ubuntu` (no tag)
- No `@sha256:` digest for immutability

#### Attack Surface

**What to look for:**
- Unnecessary packages installed
- Shell access in production images
- Debug tools left in image

**Detection patterns:**
```bash
# Find unnecessary package installs
grep -E "(vim|nano|curl|wget|git|ssh)" Dockerfile*
grep -E "apt-get install.*-y" Dockerfile*

# Check for dev dependencies in production
grep -E "npm install$" Dockerfile*          # Should be npm ci
grep -E "--production=false" Dockerfile*
```

---

### 2. Efficiency Audit

#### Layer Optimization

**What to look for:**
- Separate RUN commands that should be combined
- Large files added then deleted
- Cache-busting operations early in Dockerfile

**Detection patterns:**
```bash
# Count RUN commands (many separate RUNs = bad)
grep -c "^RUN" Dockerfile*

# Find uncleaned package manager caches
grep -E "apt-get (update|install)" Dockerfile* | grep -v "rm -rf"
grep -E "apk add" Dockerfile* | grep -v "no-cache"

# Check COPY order (dependencies should come before source)
grep -nE "^(COPY|ADD)" Dockerfile*
```

**Red flags:**
- Multiple separate `RUN apt-get install` commands
- `apt-get update` without cleanup in same layer
- `COPY . .` before `npm ci` (breaks cache)
- Large temporary files not cleaned in same RUN

#### Image Size

**What to look for:**
- Missing multi-stage builds
- Dev dependencies in production image
- Unnecessary files copied

**Detection patterns:**
```bash
# Check for multi-stage build
grep -c "^FROM" Dockerfile*   # Should be >1 for production apps

# Find heavy base images
grep -E "^FROM.*(ubuntu|debian|fedora|centos)$" Dockerfile*

# Check for .dockerignore
ls -la .dockerignore 2>/dev/null || echo "Missing .dockerignore!"

# Analyze actual image
docker images <image>
docker history <image>
```

**Red flags:**
- Single-stage build for compiled languages
- `FROM ubuntu` instead of `alpine` or `slim`
- Missing `.dockerignore` (copies node_modules, .git)
- Final image >500MB for typical apps

#### Build Cache

**What to look for:**
- Operations that bust cache unnecessarily
- Dependencies and source mixed together

**Detection patterns:**
```bash
# Check COPY order
grep -nE "^COPY" Dockerfile*

# Ideal order check (package files before source)
awk '/COPY package/ {pkg=NR} /COPY \. / {if(pkg>NR) print "Bad order"}' Dockerfile
```

---

### 3. Reliability Audit

#### Health Checks

**What to look for:**
- Missing HEALTHCHECK instruction
- Health checks that don't actually verify the app

**Detection patterns:**
```bash
# Find Dockerfiles without health checks
grep -L "HEALTHCHECK" Dockerfile*
```

**Red flags:**
- No HEALTHCHECK instruction
- HEALTHCHECK that just returns 0
- Missing health endpoint in application

#### Signal Handling

**What to look for:**
- Shell form ENTRYPOINT/CMD (breaks signals)
- Missing init process for zombie reaping

**Detection patterns:**
```bash
# Find shell form (no JSON brackets)
grep -E "^(ENTRYPOINT|CMD)[^[]" Dockerfile*

# Check for tini or dumb-init
grep -E "(tini|dumb-init)" Dockerfile*
```

**Red flags:**
- `ENTRYPOINT node app.js` (shell form)
- `CMD npm start` (shell form, no signal handling)
- Missing `--init` or tini for Node.js apps

---

### 4. Compliance Audit

#### Labels and Metadata

**What to look for:**
- Missing OCI labels
- No version/revision tracking

**Detection patterns:**
```bash
# Check for OCI labels
grep -E "^LABEL org.opencontainers" Dockerfile*
```

**Red flags:**
- No labels for source, version, maintainer
- Missing revision tracking for debugging

---

## Audit Workflow

### Quick Dockerfile Scan
1. Check for `USER` instruction (non-root)
2. Verify base image is pinned
3. Look for secrets in ARG/ENV/COPY
4. Check for multi-stage build
5. Verify `.dockerignore` exists

### Deep Container Audit
1. Run security scanner: `trivy image <image>`
2. Analyze layers: `docker history --no-trunc <image>`
3. Check running user: `docker run --rm <image> whoami`
4. Inspect image: `docker inspect <image>`
5. Test signal handling: `docker stop` should be graceful

---

## Review Checklist

### Security
- [ ] Non-root user configured
- [ ] No secrets in ARG, ENV, or COPY
- [ ] Base image pinned with SHA digest
- [ ] No unnecessary packages (vim, nano, curl)
- [ ] `.dockerignore` excludes sensitive files

### Efficiency
- [ ] Multi-stage build used
- [ ] Dependencies copied before source
- [ ] Package manager cache cleaned in same layer
- [ ] Using slim/alpine base where appropriate
- [ ] `.dockerignore` excludes node_modules, .git

### Reliability
- [ ] HEALTHCHECK configured
- [ ] Exec form used for ENTRYPOINT/CMD
- [ ] Proper signal handling (tini or --init)

---

## Output Format

When reporting Dockerfile issues:

```markdown
## Dockerfile Audit: `Dockerfile`

### Security Issues
| Severity | Line | Issue | Fix |
|----------|------|-------|-----|
| CRITICAL | - | Running as root | Add `USER appuser` |
| HIGH | 3 | Unpinned base image | Pin to specific version with SHA |
| MEDIUM | 12 | Secrets in ENV | Use runtime injection |

### Efficiency Issues
| Issue | Impact | Line | Fix |
|-------|--------|------|-----|
| Single-stage build | +200MB image | - | Add build stage |
| Cache-busting COPY | No dep cache | 8 | Copy package*.json first |

### Image Analysis
- **Size**: 847MB (should be <200MB)
- **Layers**: 23 (could be reduced to 8)
- **User**: root (should be non-root)

### Recommendations
1. Add non-root user
2. Implement multi-stage build
3. Pin base image with SHA
```

---

> **Reference**: For Dockerfile patterns and examples, see `.apm/instructions/docker.instructions.md`
