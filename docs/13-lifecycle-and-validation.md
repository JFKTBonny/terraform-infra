# 13. Lifecycle, dependencies and validation

```hcl
resource "aws_instance" "critical" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  lifecycle {
    create_before_destroy = true   # create replacement before deleting old
    prevent_destroy       = true   # block any plan that would delete it
    ignore_changes        = [tags] # ignore drift on these attributes
  }
}
```

**Replace a resource when another changes:**

```hcl
resource "terraform_data" "app_version" {
  input = var.app_version
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  lifecycle {
    replace_triggered_by = [terraform_data.app_version]
  }
}
```

**Explicit dependency** (Terraform infers most dependencies from references; use only for hidden ones):

```hcl
resource "aws_instance" "app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  depends_on = [aws_s3_bucket.logs]
}
```

**Preconditions and postconditions:**

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  lifecycle {
    precondition {
      condition     = data.aws_ami.ubuntu.architecture == "x86_64"
      error_message = "The AMI must be x86_64."
    }

    postcondition {
      condition     = self.public_ip != ""
      error_message = "The instance must have a public IP."
    }
  }
}
```

**`check` blocks** (warn without failing the apply):

```hcl
check "website_up" {
  data "http" "site" {
    url = "http://${aws_instance.web.public_ip}"
  }

  assert {
    condition     = data.http.site.status_code == 200
    error_message = "Website did not return HTTP 200."
  }
}
```

The `http` data source needs the `hashicorp/http` provider in `required_providers`.

---

← [Multiple environments](12-multiple-environments.md) · [Index](README.md) · [User data and provisioners](14-user-data-and-provisioners.md) →
