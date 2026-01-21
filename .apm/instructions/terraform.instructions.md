---
applyTo: "**/*.tf"
description: "Terraform/OpenTofu standards for infrastructure as code with HCL best practices"
---

# Terraform Standards

## File Structure

### Standard Layout

```
infrastructure/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   └── production/
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── compute/
│   └── database/
└── shared/
    └── providers.tf
```

### File Naming Conventions

| File | Contents |
|------|----------|
| `main.tf` | Primary resources and module calls |
| `variables.tf` | Input variable declarations |
| `outputs.tf` | Output value declarations |
| `providers.tf` | Provider configurations |
| `backend.tf` | State backend configuration |
| `versions.tf` | Required provider versions |
| `locals.tf` | Local value definitions |
| `data.tf` | Data source definitions |

## Resource Naming

### Naming Conventions

```hcl
# Use snake_case for resource names
resource "aws_instance" "web_server" { }      # Good
resource "aws_instance" "webServer" { }       # Bad
resource "aws_instance" "web-server" { }      # Bad

# Names should describe purpose, not type
resource "aws_security_group" "web_ingress" { }   # Good
resource "aws_security_group" "sg_1" { }          # Bad

# Use descriptive names for data sources
data "aws_ami" "ubuntu_latest" { }
data "aws_caller_identity" "current" { }
```

### Resource Tagging

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Repository  = var.repository_url
  }
}

resource "aws_instance" "web" {
  # ... configuration ...
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-web-${var.environment}"
    Role = "webserver"
  })
}
```

## Variables

### Variable Definitions

```hcl
# Always include description and type
variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
  
  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Instance type must be from the t3 family."
  }
}

# Use objects for complex configurations
variable "database_config" {
  description = "Database configuration settings"
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    storage_gb     = number
    multi_az       = bool
  })
  
  default = {
    engine         = "postgres"
    engine_version = "15"
    instance_class = "db.t3.micro"
    storage_gb     = 20
    multi_az       = false
  }
}

# Mark sensitive variables
variable "database_password" {
  description = "Master password for database"
  type        = string
  sensitive   = true
}
```

### Variable Validation

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "Must be a valid CIDR block."
  }
}
```

## Outputs

### Output Best Practices

```hcl
# Always include description
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

# Mark sensitive outputs
output "database_connection_string" {
  description = "Database connection string"
  value       = "postgres://${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
  sensitive   = true
}

# Use depends_on when needed
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
  depends_on  = [aws_eks_cluster.main]
}
```

## Modules

### Module Structure

```hcl
# modules/networking/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}

# modules/networking/variables.tf
variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# modules/networking/outputs.tf
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}
```

### Module Usage

```hcl
module "networking" {
  source = "../../modules/networking"
  
  name     = var.project_name
  vpc_cidr = "10.0.0.0/16"
  tags     = local.common_tags
}

# Version-pinned external modules
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"  # Always pin versions
  
  name = var.project_name
  cidr = "10.0.0.0/16"
}
```

## State Management

### Remote Backend Configuration

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "environments/production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
    
    # Use OIDC in CI/CD, not hardcoded credentials
  }
}
```

### State Locking

```hcl
# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = local.common_tags
}
```

### Workspace Usage

```hcl
# Use workspaces for environment separation
locals {
  environment = terraform.workspace
  
  instance_type = {
    dev        = "t3.micro"
    staging    = "t3.small"
    production = "t3.medium"
  }[local.environment]
}

resource "aws_instance" "web" {
  instance_type = local.instance_type
  # ...
}
```

## Provider Configuration

### Version Constraints

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
```

### Provider Aliases

```hcl
# Multi-region setup
provider "aws" {
  region = "us-east-1"
  alias  = "us_east"
}

provider "aws" {
  region = "eu-west-1"
  alias  = "eu_west"
}

resource "aws_s3_bucket" "primary" {
  provider = aws.us_east
  bucket   = "my-bucket-us"
}

resource "aws_s3_bucket" "replica" {
  provider = aws.eu_west
  bucket   = "my-bucket-eu"
}
```

## Resource Patterns

### Lifecycle Rules

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true  # Production safety
    
    ignore_changes = [
      tags["LastModified"],  # Ignore external tag changes
    ]
  }
}
```

### Conditional Resources

```hcl
# Count-based conditionals
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.enable_monitoring ? 1 : 0
  
  alarm_name = "${var.name}-high-cpu"
  # ...
}

# For_each for multiple resources
resource "aws_security_group_rule" "ingress" {
  for_each = var.ingress_rules
  
  type              = "ingress"
  security_group_id = aws_security_group.main.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
}
```

### Dynamic Blocks

```hcl
resource "aws_security_group" "main" {
  name   = var.name
  vpc_id = var.vpc_id
  
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Data Sources

### Common Patterns

```hcl
# Current AWS account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Latest AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Existing resources
data "aws_vpc" "existing" {
  id = var.vpc_id
}
```

## Locals

### Effective Use of Locals

```hcl
locals {
  # Computed values
  name_prefix = "${var.project}-${var.environment}"
  
  # Common tags
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  
  # Derived configurations
  is_production = var.environment == "production"
  
  # Complex transformations
  subnet_cidrs = [
    for i in range(var.subnet_count) :
    cidrsubnet(var.vpc_cidr, 8, i)
  ]
}
```

## Security Best Practices

### Secrets Management

```hcl
# Never hardcode secrets
# Bad
resource "aws_db_instance" "bad" {
  password = "hardcoded-password"  # Never do this
}

# Good - use variables marked sensitive
resource "aws_db_instance" "good" {
  password = var.database_password  # Pass via TF_VAR or secrets manager
}

# Better - use secrets manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "production/database/password"
}

resource "aws_db_instance" "best" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

### Encryption

```hcl
# Always encrypt at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.main.arn
    }
  }
}

resource "aws_db_instance" "main" {
  storage_encrypted = true
  kms_key_id        = aws_kms_key.main.arn
  # ...
}
```

## CI/CD Integration

### GitHub Actions Example

```yaml
# See github-actions.instructions.md for full details
jobs:
  terraform:
    steps:
      - uses: hashicorp/setup-terraform@v3
      
      - name: Terraform Format Check
        run: terraform fmt -check -recursive
      
      - name: Terraform Init
        run: terraform init -backend-config="environments/${{ inputs.environment }}/backend.hcl"
      
      - name: Terraform Validate
        run: terraform validate
      
      - name: Terraform Plan
        run: terraform plan -out=tfplan -var-file="environments/${{ inputs.environment }}/terraform.tfvars"
      
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve tfplan
```

### Plan Output in PRs

```hcl
# Use terraform-docs for documentation
# Install: brew install terraform-docs

# Generate docs
# terraform-docs markdown table . > README.md
```

## Anti-Patterns

### Avoid These Patterns

```hcl
# Bad: Hardcoded values
resource "aws_instance" "web" {
  ami           = "ami-12345678"  # Hardcoded AMI
  instance_type = "t3.micro"      # No variable
}

# Bad: No version constraints
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Missing version constraint
    }
  }
}

# Bad: Secrets in state
resource "random_password" "db" {
  length = 16
}
# This password is now in plaintext in state

# Bad: count with complex logic
resource "aws_instance" "web" {
  count = var.create_instance && var.environment != "dev" ? var.instance_count : 0
  # Hard to understand, use locals
}
```

### Preferred Patterns

```hcl
# Good: Data source for AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  # ...
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
}

# Good: Clear version constraints
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Good: Secrets from external store
data "aws_secretsmanager_secret_version" "db" {
  secret_id = var.db_secret_id
}

# Good: Readable conditional logic
locals {
  should_create = var.create_instance && !local.is_dev
  instance_count = local.should_create ? var.instance_count : 0
}

resource "aws_instance" "web" {
  count = local.instance_count
}
```

## Formatting and Validation

### Commands

```bash
# Format all files
terraform fmt -recursive

# Validate configuration
terraform validate

# Check formatting without changes
terraform fmt -check -recursive

# Generate documentation
terraform-docs markdown . > README.md
```

### Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: terraform_trivy
```
