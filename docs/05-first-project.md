# 5. First project

A single Ubuntu web server in the default VPC. The same code is in [`examples/01-single-ec2`](../examples/01-single-ec2).

**versions.tf**

```hcl
terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

**variables.tf**

```hcl
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "demo"
}
```

**main.tf**

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Allow HTTP in, everything out"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl enable --now nginx
  EOF

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name    = "${var.project_name}-web"
    Project = var.project_name
  }
}
```

> Security group rules are written as separate `aws_vpc_security_group_ingress_rule` / `egress_rule` resources. AWS provider docs recommend this over inline `ingress {}` / `egress {}` blocks.

**outputs.tf**

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "url" {
  description = "URL of the web server"
  value       = "http://${aws_instance.web.public_ip}"
}
```

**Authenticate and run:**

```bash
# Option A: AWS CLI profile (recommended)
aws configure            # or: aws sso login --profile myprofile
export AWS_PROFILE=default

# Option B: environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
```

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```

---

← [Project files](04-project-files.md) · [Index](README.md) · [Variables](06-variables.md) →
