---
name: security
description: DevSecOps practices for CI/CD and infrastructure. Covers OIDC authentication, secrets management, supply chain security, container hardening, and security scanning.
---

# DevSecOps Patterns

Security practices integrated into CI/CD pipelines and infrastructure.

## Core Principles

1. **Security as Code** - Policies in version control
2. **Shift Left** - Scan early, fail fast
3. **Zero Trust** - Verify everything, trust nothing
4. **Least Privilege** - Minimal permissions always
5. **Immutable Infrastructure** - Replace, don't patch

## Authentication Hierarchy

| Method | Security | Use Case |
|--------|----------|----------|
| OIDC | Best | Cloud providers (AWS, GCP, Azure) |
| Short-lived tokens | Better | API access, temporary creds |
| Repository secrets | Good | Third-party services |
| Long-lived credentials | Avoid | Legacy systems only |

## OIDC Authentication

### GitHub Actions → AWS

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
      aws-region: us-east-1
```

### AWS Trust Policy

```hcl
resource "aws_iam_role" "github_actions" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:org/repo:*"
        }
      }
    }]
  })
}
```

## Supply Chain Security

### Pin Actions by SHA

```yaml
# Bad - tag can be moved
- uses: actions/checkout@v4

# Good - immutable
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```

### Enable Dependabot

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
```

### Sign Artifacts

```yaml
- name: Sign image
  run: cosign sign --yes ghcr.io/${{ github.repository }}:${{ github.sha }}
```

### SBOM Generation

```yaml
- uses: anchore/sbom-action@v0
  with:
    image: ghcr.io/${{ github.repository }}:${{ github.sha }}
```

## Secrets Management

### By Platform

| Platform | Secret Store | Best Practice |
|----------|--------------|---------------|
| GitHub Actions | Repository secrets | Environment protection rules |
| Jenkins | Credentials plugin | Folder-scoped credentials |
| Terraform | External only | Vault / cloud secrets manager |
| Docker | Never in image | Runtime injection |

### GitHub Actions

```yaml
# Never echo secrets
- run: |
    echo "::add-mask::${{ secrets.API_KEY }}"

# Use environments for approval
jobs:
  deploy:
    environment: production  # Requires approval
```

### Terraform

```hcl
# Use external secrets manager
data "aws_secretsmanager_secret_version" "db" {
  secret_id = var.db_secret_id
}

# Never in state
resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db.secret_string
}
```

## Container Security

### Non-Root User (Required)

```dockerfile
RUN addgroup -S app && adduser -S app -G app
USER app
```

### Minimal Base Images

```dockerfile
# Use distroless (no shell, minimal attack surface)
FROM gcr.io/distroless/nodejs20
```

### No Secrets in Images

```dockerfile
# Bad
COPY .env ./
ARG DATABASE_PASSWORD

# Good - runtime only
# docker run -e DATABASE_PASSWORD=...
```

### Security Scanning

```yaml
# Trivy scan in CI
- name: Scan image
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myimage:latest
    severity: 'CRITICAL,HIGH'
    exit-code: '1'
```

## CI/CD Security Checklist

### GitHub Actions
- [ ] Explicit `permissions:` block
- [ ] OIDC for cloud authentication
- [ ] Actions pinned by SHA
- [ ] Environment protection rules
- [ ] No secrets in logs
- [ ] Dependabot enabled

### Docker
- [ ] Non-root user
- [ ] Distroless or minimal base
- [ ] No secrets in build
- [ ] Image scanning in CI
- [ ] Signed images

### Terraform
- [ ] Remote state with encryption
- [ ] State locking enabled
- [ ] Secrets from external manager
- [ ] `prevent_destroy` on critical resources
- [ ] Plan review before apply

## Security Scanning Tools

| Type | Tool | Integration |
|------|------|-------------|
| Container | Trivy, Grype | CI action |
| Dependencies | Dependabot, Snyk | GitHub integration |
| IaC | tfsec, checkov | Pre-commit / CI |
| Secrets | Gitleaks, TruffleHog | Pre-commit |
| SAST | Semgrep, CodeQL | GitHub Actions |

## Common Vulnerabilities

| Issue | Fix |
|-------|-----|
| Exposed secrets | External secrets manager + scanning |
| Root containers | Non-root USER directive |
| Unpinned deps | Lockfiles + version pinning |
| Missing OIDC | Replace long-lived credentials |
| No scanning | Add Trivy/Snyk to CI |
