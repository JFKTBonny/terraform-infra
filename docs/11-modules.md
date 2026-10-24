# 11. Modules

A module is a folder of `.tf` files. The folder where you run `terraform` is the **root module**; folders it calls are **child modules**.

**Rules for child modules:**
- Declare `required_providers`, but **no `provider` block** and **no `backend` block**.
- Take everything as variables, expose results as outputs.

**Structure:**

```
project/
├── main.tf
└── modules/
    └── web-server/
        ├── versions.tf
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

**modules/web-server/versions.tf**

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
```

**modules/web-server/variables.tf**

```hcl
variable "name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  type = string
}
```

**modules/web-server/main.tf**

```hcl
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.name
  }
}
```

**modules/web-server/outputs.tf**

```hcl
output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}
```

**Calling the module (root main.tf):**

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

module "web_dev" {
  source = "./modules/web-server"

  name          = "web-dev"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
}

module "web_prod" {
  source = "./modules/web-server"

  name          = "web-prod"
  ami_id        = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
}

output "dev_ip" {
  value = module.web_dev.public_ip
}

output "prod_ip" {
  value = module.web_prod.public_ip
}
```

**Module with `for_each`:**

```hcl
module "web" {
  source   = "./modules/web-server"
  for_each = toset(["api", "admin"])

  name   = "web-${each.key}"
  ami_id = data.aws_ami.ubuntu.id
}

output "web_ips" {
  value = { for k, m in module.web : k => m.public_ip }
}
```

**Public registry module:**

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-south-1a", "eu-south-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "dev"
  }
}
```

**Module from git (pinned to a tag):**

```hcl
module "network" {
  source = "git::https://github.com/myorg/terraform-modules.git//network?ref=v1.2.0"
}
```

Run `terraform init` after adding a module or changing its `source` / `version`.

---

← [State and remote backends](10-state-and-backends.md) · [Index](README.md) · [Multiple environments](12-multiple-environments.md) →
