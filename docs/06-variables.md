# 6. Variables

**Types, validation, sensitive values:**

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "enable_monitoring" {
  type    = bool
  default = false
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-south-1a", "eu-south-1b"]
}

variable "tags" {
  type = map(string)
  default = {
    Owner = "platform-team"
    Team  = "devops"
  }
}

variable "server_config" {
  type = object({
    name = string
    size = string
    disk = optional(number, 20)
  })
  default = {
    name = "app"
    size = "t3.small"
  }
}

variable "db_password" {
  type      = string
  sensitive = true
}
```

`optional(type, default)` makes an object attribute optional with a default value.

**Where values come from (later in the list wins):**

1. `default` in the variable block
2. Environment variables: `TF_VAR_<name>`
3. `terraform.tfvars`
4. `terraform.tfvars.json`
5. `*.auto.tfvars` / `*.auto.tfvars.json` (alphabetical order)
6. `-var` and `-var-file` on the command line (in the order you write them)

**terraform.tfvars**

```hcl
environment        = "dev"
instance_count     = 3
enable_monitoring  = true
availability_zones = ["eu-south-1a", "eu-south-1b", "eu-south-1c"]

tags = {
  Owner = "alice"
  Team  = "backend"
}
```

**Command line:**

```bash
export TF_VAR_db_password="s3cr3t"
terraform apply -var-file="prod.tfvars"
terraform apply -var="environment=prod" -var="instance_count=5"
```

---

← [First project](05-first-project.md) · [Index](README.md) · [Locals](07-locals.md) →
