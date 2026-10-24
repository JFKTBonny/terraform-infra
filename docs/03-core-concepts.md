# 3. Core concepts

| Concept | Meaning |
|---|---|
| **Provider** | Plugin that talks to an API (AWS, Azure, GCP, Kubernetes, GitHub…) |
| **Resource** | Something Terraform creates and manages (VM, bucket, network) |
| **Data source** | Reads existing information without managing it |
| **Variable** | Input parameter |
| **Output** | Value exported after apply |
| **Local** | Named expression reused inside a configuration |
| **Module** | Reusable folder of `.tf` files |
| **State** | File (`terraform.tfstate`) mapping your code to real resources |
| **Backend** | Where state is stored (local disk, S3, Azure Blob, GCS, HCP Terraform) |

**Block syntax:**

```hcl
resource "<PROVIDER>_<TYPE>" "<LOCAL_NAME>" {
  argument = "value"

  nested_block {
    argument = "value"
  }
}
```

**References:**

| What | Syntax | Example |
|---|---|---|
| Resource attribute | `<TYPE>.<NAME>.<ATTR>` | `aws_instance.web.public_ip` |
| Data source | `data.<TYPE>.<NAME>.<ATTR>` | `data.aws_ami.ubuntu.id` |
| Variable | `var.<NAME>` | `var.instance_type` |
| Local | `local.<NAME>` | `local.common_tags` |
| Module output | `module.<NAME>.<OUTPUT>` | `module.network.vpc_id` |
| String interpolation | `"${...}"` | `"web-${var.environment}"` |

---

← [Installation](02-installation.md) · [Index](README.md) · [Project files](04-project-files.md) →
