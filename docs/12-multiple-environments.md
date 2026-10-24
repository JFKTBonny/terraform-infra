# 12. Multiple environments

**Option A — one folder per environment (recommended; used in this repo):**

```
environments/
├── dev/
│   ├── backend.tf        # key = "dev/terraform.tfstate"
│   ├── versions.tf
│   ├── main.tf           # calls ../../modules/*
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
└── prod/
    └── ...               # same files, key = "prod/terraform.tfstate"
modules/
├── network/
└── web-server/
```

Each environment has separate state and can be planned, applied, and protected separately.

**Option B — workspaces (same code, one state per workspace):**

```bash
terraform workspace new dev
terraform workspace new prod
terraform workspace list
terraform workspace select prod
terraform workspace show
```

```hcl
locals {
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type

  tags = {
    Name = "web-${terraform.workspace}"
  }
}
```

With the S3 backend, workspace states are stored under `env:/<workspace>/<key>`.

| | Folders | Workspaces |
|---|---|---|
| Different code per env | Easy | Needs conditionals |
| Separate backend / account per env | Yes | No (same backend) |
| Risk of applying to wrong env | Low (you `cd`) | Higher (forgot `select`) |
| Best for | Real dev/staging/prod | Short-lived copies, feature stacks |

---

← [Modules](11-modules.md) · [Index](README.md) · [Lifecycle, dependencies and validation](13-lifecycle-and-validation.md) →
