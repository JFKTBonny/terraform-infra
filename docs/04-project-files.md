# 4. Project files

Terraform loads **every `.tf` file in a folder** as one configuration. File names are a convention:

```
my-project/
├── versions.tf         # terraform block + provider config
├── backend.tf          # where state is stored
├── main.tf             # resources and module calls
├── variables.tf        # input variables
├── outputs.tf          # outputs
├── terraform.tfvars    # variable values
└── .terraform.lock.hcl # provider version lock (generated, COMMIT it)
```

**.gitignore:**

```gitignore
# Terraform working directories
**/.terraform/

# State files
*.tfstate
*.tfstate.*

# Plan files
*.tfplan
tfplan

# Crash logs
crash.log
crash.*.log

# Secret variable files
*.secret.tfvars
secrets.auto.tfvars

# Override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# CLI config
.terraformrc
terraform.rc
```

> Commit `terraform.tfvars` only if it contains **no secrets**. Commit `.terraform.lock.hcl` always.

---

← [Core concepts](03-core-concepts.md) · [Index](README.md) · [First project](05-first-project.md) →
