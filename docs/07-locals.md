# 7. Locals

Locals give a name to an expression so you don't repeat it.

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.name_prefix}-logs"
  tags   = local.common_tags
}
```

> For AWS, `default_tags` in the provider block applies tags to every resource automatically:

```hcl
provider "aws" {
  region = "eu-south-1"

  default_tags {
    tags = {
      Project   = "myapp"
      ManagedBy = "terraform"
    }
  }
}
```

---

← [Variables](06-variables.md) · [Index](README.md) · [Loops and conditionals](08-loops-and-conditionals.md) →
