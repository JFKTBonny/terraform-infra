# 9. Data sources

Data sources read existing infrastructure without managing it.

```hcl
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "region" {
  value = data.aws_region.current.region
}

output "subnet_ids" {
  value = data.aws_subnets.default.ids
}

output "azs" {
  value = data.aws_availability_zones.available.names
}
```

**Reading a secret from AWS Secrets Manager:**

```hcl
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "myapp/db-password"
}

locals {
  db_password = data.aws_secretsmanager_secret_version.db.secret_string
}
```

> Values read this way are still written to the state file. Protect state (encryption, access control).

---

← [Loops and conditionals](08-loops-and-conditionals.md) · [Index](README.md) · [State and remote backends](10-state-and-backends.md) →
