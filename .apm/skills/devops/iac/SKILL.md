---
name: iac
description: Infrastructure as Code review methodology. Use when auditing Terraform/OpenTofu configurations for security, reliability, and best practices. Focuses on HOW TO REVIEW IaC, not how to write it.
---

# Infrastructure as Code Review Methodology

This skill teaches you HOW TO REVIEW Terraform/OpenTofu configurations. For HOW TO WRITE IaC, see `.apm/instructions/terraform.instructions.md`.

## Review Approach

### 1. Security Review

#### Secrets Detection

**What to look for:**
- Hardcoded credentials in variables or resources
- Sensitive values not marked as sensitive
- Secrets stored in state file

**Detection patterns:**
```bash
# Find hardcoded secrets
grep -rE "(password|secret|key|token)\s*=\s*\"[^\"]+\"" *.tf
grep -rE "access_key|secret_key" *.tf

# Find variables that should be sensitive
grep -B2 -E "(password|secret|key|token)" variables.tf | grep -v "sensitive.*true"

# Find plaintext in outputs
grep -A3 "^output" outputs.tf | grep -v "sensitive.*true" | grep -E "(password|secret|key)"
```

**Red flags:**
- `password = "hardcoded123"`
- Variables without `sensitive = true` for secrets
- Outputs exposing sensitive values
- `random_password` without external secret storage

#### Encryption Gaps

**What to look for:**
- S3 buckets without encryption
- RDS/databases without encryption at rest
- Missing KMS key usage

**Detection patterns:**
```bash
# Find unencrypted S3 buckets
grep -rE "aws_s3_bucket\s+" *.tf -l | xargs grep -L "server_side_encryption"

# Find unencrypted RDS
grep -A20 "aws_db_instance" *.tf | grep -E "(storage_encrypted|kms_key)"

# Find EBS volumes without encryption
grep -A10 "aws_ebs_volume" *.tf | grep -L "encrypted.*true"
```

**Red flags:**
- S3 buckets without `server_side_encryption_configuration`
- RDS without `storage_encrypted = true`
- EBS volumes without encryption
- Missing `kms_key_id` references

#### Network Security

**What to look for:**
- Overly permissive security groups
- Public access to sensitive resources
- Missing VPC configuration

**Detection patterns:**
```bash
# Find wide-open CIDR blocks
grep -rE 'cidr_blocks.*"0\.0\.0\.0/0"' *.tf
grep -rE 'cidr_blocks.*"::/0"' *.tf

# Find public resources
grep -rE "publicly_accessible\s*=\s*true" *.tf
grep -rE "map_public_ip_on_launch\s*=\s*true" *.tf

# Find security groups with all traffic allowed
grep -A5 'protocol\s*=\s*"-1"' *.tf
```

**Red flags:**
- Ingress from `0.0.0.0/0` on sensitive ports (22, 3306, 5432)
- `publicly_accessible = true` on RDS
- Security groups allowing all egress without justification
- Missing VPC endpoints for AWS services

---

### 2. Reliability Review

#### State Management

**What to look for:**
- Local state instead of remote backend
- Missing state locking
- Unencrypted state storage

**Detection patterns:**
```bash
# Check for remote backend
grep -rE "backend\s+\"(s3|azurerm|gcs|remote)\"" *.tf
ls backend.tf 2>/dev/null || echo "No backend.tf found"

# Check for state locking
grep -rE "dynamodb_table" backend.tf 2>/dev/null
```

**Red flags:**
- No `backend.tf` file
- `backend "local"` in production
- Missing `dynamodb_table` for S3 backend
- `encrypt = false` in backend config

#### Version Constraints

**What to look for:**
- Missing terraform version constraints
- Unpinned provider versions
- Missing module version pinning

**Detection patterns:**
```bash
# Check version constraints
grep -A5 "required_version" *.tf
grep -A10 "required_providers" *.tf | grep "version"

# Check module version pinning
grep -A3 "source.*=" *.tf | grep -E "(version|ref=)"
```

**Red flags:**
- No `required_version` constraint
- Provider without `version = "~> X.Y"`
- Registry modules without version pinning
- Git modules without `ref=` tag

#### Lifecycle Safety

**What to look for:**
- Resources that could be accidentally destroyed
- Missing `prevent_destroy` on critical resources
- Force-new changes without awareness

**Detection patterns:**
```bash
# Find resources without lifecycle protection
grep -rE "aws_(db_instance|s3_bucket|dynamodb_table)" *.tf -l | \
  xargs grep -L "prevent_destroy"

# Find resources with replace triggers
grep -rE "create_before_destroy|replace_triggered_by" *.tf
```

**Red flags:**
- Production databases without `prevent_destroy = true`
- S3 buckets without lifecycle protection
- Resources with implicit force-new changes

---

### 3. Code Quality Review

#### Naming and Structure

**What to look for:**
- Inconsistent naming conventions
- Missing variable descriptions
- Poor file organization

**Detection patterns:**
```bash
# Find variables without descriptions
grep -B1 "^variable" variables.tf | grep -A1 "variable" | grep -v "description"

# Find outputs without descriptions
grep -B1 "^output" outputs.tf | grep -A1 "output" | grep -v "description"

# Find non-snake_case resource names
grep -rE 'resource "[^"]+"\s+"[^"]*[A-Z]' *.tf
grep -rE 'resource "[^"]+"\s+"[^"]*-' *.tf
```

**Red flags:**
- Variables without descriptions
- CamelCase or kebab-case resource names
- Hardcoded values that should be variables
- Missing `locals.tf` for computed values

#### DRY and Modularity

**What to look for:**
- Repeated resource patterns
- Missing module extraction
- Complex count/for_each logic

**Detection patterns:**
```bash
# Find repeated patterns
grep -c "aws_instance" *.tf              # Many instances = use module
grep -c "aws_security_group_rule" *.tf   # Many rules = use dynamic

# Find complex conditionals
grep -E "count.*\?.*:" *.tf
grep -E "for_each.*if" *.tf
```

---

### 4. Plan Review

#### Pre-Apply Checks

**Commands to run:**
```bash
# Format check
terraform fmt -check -recursive

# Validation
terraform validate

# Plan review
terraform plan -out=tfplan
terraform show -json tfplan | jq '.resource_changes[] | select(.change.actions | contains(["delete"]))'

# Security scanning
tfsec .
checkov -d .
```

#### Plan Analysis

**What to look for in plan:**
- Unexpected destroys or replacements
- Force-new changes on stateful resources
- Drift from expected changes

**Red flags in plan:**
- `# forces replacement` on databases/volumes
- Resources being destroyed unexpectedly
- Changes to resources not in PR scope
- Modifications to production secrets

---

## Review Checklist

### Security
- [ ] No hardcoded secrets (passwords, API keys)
- [ ] Sensitive variables marked with `sensitive = true`
- [ ] Encryption enabled for storage (S3, RDS, EBS)
- [ ] Security groups don't allow `0.0.0.0/0` on sensitive ports
- [ ] Secrets sourced from secrets manager, not variables

### Reliability
- [ ] Remote backend configured with locking
- [ ] Terraform version constrained (`>= 1.5.0`)
- [ ] Provider versions pinned (`~> 5.0`)
- [ ] Module versions pinned
- [ ] Critical resources have `prevent_destroy`

### Quality
- [ ] All variables have descriptions
- [ ] snake_case naming convention used
- [ ] Common patterns extracted to modules
- [ ] Tags applied via `locals.common_tags`
- [ ] Complex logic moved to locals

---

## Output Format

When reporting Terraform issues:

```markdown
## Terraform Review: `infrastructure/production/`

### Security Issues
| Severity | File | Issue | Fix |
|----------|------|-------|-----|
| CRITICAL | main.tf:23 | Hardcoded database password | Use aws_secretsmanager_secret |
| HIGH | sg.tf:15 | SSH open to 0.0.0.0/0 | Restrict to bastion/VPN CIDR |
| MEDIUM | rds.tf:8 | Missing encryption at rest | Add `storage_encrypted = true` |

### Reliability Issues
| Issue | File | Risk | Fix |
|-------|------|------|-----|
| No version constraint | versions.tf | Provider drift | Add `version = "~> 5.0"` |
| Missing prevent_destroy | rds.tf | Accidental deletion | Add lifecycle block |

### Plan Analysis
- **Creates**: 3 resources
- **Updates**: 2 resources  
- **Destroys**: 0 resources (safe)

### Recommendations
1. Move database password to Secrets Manager
2. Add encryption to all storage resources
3. Pin provider versions
```

---

> **Reference**: For Terraform patterns and syntax, see `.apm/instructions/terraform.instructions.md`
