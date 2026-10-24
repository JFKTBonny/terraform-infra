# 1. What Terraform is

Terraform is an **Infrastructure as Code (IaC)** tool. You describe infrastructure (servers, networks, databases, DNS) in `.tf` files written in **HCL** (HashiCorp Configuration Language). Terraform then creates, updates, or deletes real resources so they match your code.

**Workflow:**

```
Write (.tf) → terraform init → terraform plan → terraform apply → terraform destroy
```

| Step | What it does |
|---|---|
| `init` | Downloads providers and modules, configures the backend |
| `plan` | Shows what would change (dry run) |
| `apply` | Makes the changes |
| `destroy` | Deletes everything this configuration manages |

> **OpenTofu** is an open-source fork of Terraform with the same language and commands (`tofu` instead of `terraform`). Everything in this guide works in both, unless noted.

---

[Index](README.md) · [Installation](02-installation.md) →
