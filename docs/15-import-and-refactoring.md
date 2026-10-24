# 15. Import and refactoring

**Import an existing resource (`import` block, Terraform 1.5+):**

```hcl
import {
  to = aws_s3_bucket.existing
  id = "my-existing-bucket-name"
}

resource "aws_s3_bucket" "existing" {
  bucket = "my-existing-bucket-name"
}
```

```bash
terraform plan
terraform apply
```

**Generate the resource code for you** (experimental feature; review the output):

```hcl
import {
  to = aws_s3_bucket.existing
  id = "my-existing-bucket-name"
}
```

```bash
terraform plan -generate-config-out=generated.tf
```

**Rename or move a resource without destroying it:**

```hcl
moved {
  from = aws_instance.web
  to   = aws_instance.frontend
}
```

```hcl
moved {
  from = aws_instance.web
  to   = module.web.aws_instance.this
}
```

**Stop managing a resource without deleting it (Terraform 1.7+):**

```hcl
removed {
  from = aws_instance.old

  lifecycle {
    destroy = false
  }
}
```

Delete the original `resource` block when you add `removed`. Keep `moved` / `removed` blocks until every environment has applied them.

---

← [User data and provisioners](14-user-data-and-provisioners.md) · [Index](README.md) · [Built-in functions](16-functions.md) →
