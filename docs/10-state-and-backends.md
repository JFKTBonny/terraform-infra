# 10. State and remote backends

State tracks what Terraform manages. **Never edit it by hand. Never commit it to git.** For any shared project, store it remotely with locking and versioning.

**Step 1 — create the state bucket (one-time, separate folder with local state).** Full version in [`bootstrap/`](../bootstrap).

```hcl
provider "aws" {
  region = "eu-south-1"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "mycompany-terraform-state-12345"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

**Step 2 — use it as the backend:**

```hcl
terraform {
  backend "s3" {
    bucket       = "mycompany-terraform-state-12345"
    key          = "myproject/dev/terraform.tfstate"
    region       = "eu-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

`use_lockfile = true` uses native S3 locking (a `.tflock` object next to the state). It was added in Terraform 1.10 and is generally available from 1.11. DynamoDB-based locking (`dynamodb_table`) is deprecated.

```bash
terraform init                   # new project
terraform init -migrate-state    # moving existing local state into the backend
```

**Azure backend** (locking via blob lease, built in):

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate12345"
    container_name       = "tfstate"
    key                  = "myproject.terraform.tfstate"
    use_azuread_auth     = true
  }
}
```

**GCP backend** (locking built in):

```hcl
terraform {
  backend "gcs" {
    bucket = "mycompany-tf-state"
    prefix = "myproject/dev"
  }
}
```

**Partial backend config** (keep values out of code, pass at init):

```hcl
terraform {
  backend "s3" {}
}
```

```bash
terraform init -backend-config="bucket=mycompany-terraform-state-12345" -backend-config="key=dev/terraform.tfstate" -backend-config="region=eu-south-1" -backend-config="use_lockfile=true"
```

**State commands:**

```bash
terraform state list
terraform state show aws_instance.web
terraform state mv aws_instance.web aws_instance.frontend
terraform state rm aws_instance.web
terraform state pull > backup.tfstate
terraform force-unlock <LOCK_ID>
```

> Prefer `moved {}` and `removed {}` blocks ([Import and refactoring](15-import-and-refactoring.md)) over `state mv` / `state rm`: they are reviewed in a PR and applied by CI like any other change.

**Reading another configuration's outputs:**

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "mycompany-terraform-state-12345"
    key    = "network/terraform.tfstate"
    region = "eu-south-1"
  }
}

locals {
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
}
```

---

← [Data sources](09-data-sources.md) · [Index](README.md) · [Modules](11-modules.md) →
