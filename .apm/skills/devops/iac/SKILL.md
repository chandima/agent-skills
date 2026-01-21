---
name: iac
description: Infrastructure as Code patterns with Terraform/OpenTofu. Covers file structure, resource naming, variables, modules, state management, and security best practices.
---

# Infrastructure as Code

Terraform/OpenTofu patterns for managing cloud infrastructure as code.

## Tool Selection

| Requirement | Terraform | CloudFormation | Pulumi |
|-------------|-----------|----------------|--------|
| Multi-cloud | Best | AWS only | Good |
| State mgmt | Required | Built-in | Required |
| Language | HCL | YAML/JSON | Any |
| **Default** | **Yes** | AWS-only | Dev teams |

## File Structure

```
infrastructure/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── production/
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── compute/
└── shared/
    └── providers.tf
```

## Naming Conventions

```hcl
# snake_case for resource names
resource "aws_instance" "web_server" { }      # Good
resource "aws_instance" "webServer" { }       # Bad

# Descriptive names
resource "aws_security_group" "web_ingress" { }   # Good
resource "aws_security_group" "sg_1" { }          # Bad
```

## Variables

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Must be t3 family."
  }
}

variable "database_password" {
  description = "DB password"
  type        = string
  sensitive   = true  # Mark sensitive
}
```

## Modules

```hcl
# Module definition
module "networking" {
  source = "../../modules/networking"
  
  name     = var.project_name
  vpc_cidr = "10.0.0.0/16"
  tags     = local.common_tags
}

# External modules - always pin versions
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"
}
```

## State Management

```hcl
# Remote backend
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "environments/production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"  # State locking
  }
}
```

## Provider Configuration

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Always pin
    }
  }
}
```

## Resource Patterns

### Lifecycle Rules

```hcl
resource "aws_instance" "web" {
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true  # Production safety
    ignore_changes        = [tags["LastModified"]]
  }
}
```

### Conditionals

```hcl
# Count-based
resource "aws_alarm" "cpu" {
  count = var.enable_monitoring ? 1 : 0
}

# For_each for multiple
resource "aws_security_group_rule" "ingress" {
  for_each = var.ingress_rules
  from_port = each.value.from_port
  # ...
}
```

## Locals

```hcl
locals {
  name_prefix   = "${var.project}-${var.environment}"
  is_production = var.environment == "production"
  
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
```

## Security Best Practices

### Secrets Management

```hcl
# Never hardcode
resource "aws_db_instance" "bad" {
  password = "hardcoded"  # Never!
}

# Use secrets manager
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "production/database/password"
}

resource "aws_db_instance" "good" {
  password = data.aws_secretsmanager_secret_version.db.secret_string
}
```

### Encryption

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}
```

## Anti-Patterns

| Bad | Good |
|-----|------|
| Hardcoded AMI IDs | Data source lookup |
| No version constraints | Pin all versions |
| Secrets in state | External secrets manager |
| Complex count logic | Use locals for clarity |
| Missing descriptions | Document all variables |

## Commands

```bash
terraform fmt -recursive      # Format
terraform validate            # Validate
terraform plan -out=tfplan    # Plan
terraform apply tfplan        # Apply
```

> **Full Reference**: See `.apm/instructions/terraform.instructions.md` for complete details.
