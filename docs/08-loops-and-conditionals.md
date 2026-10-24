# 8. Loops and conditionals

**`count` — N identical copies:**

```hcl
resource "aws_instance" "app" {
  count         = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "app-${count.index}"
  }
}

output "app_ips" {
  value = aws_instance.app[*].public_ip
}
```

**`for_each` with a map — preferred, keyed by name (removing one item doesn't shift the others):**

```hcl
variable "buckets" {
  type = map(string)
  default = {
    logs    = "Application logs"
    assets  = "Static assets"
    backups = "Database backups"
  }
}

resource "aws_s3_bucket" "this" {
  for_each = var.buckets
  bucket   = "myproject-${each.key}"

  tags = {
    Name    = each.key
    Purpose = each.value
  }
}

output "bucket_names" {
  value = { for k, b in aws_s3_bucket.this : k => b.bucket }
}
```

**`for_each` with a set of strings:**

```hcl
resource "aws_iam_user" "users" {
  for_each = toset(["alice", "bob", "carol"])
  name     = each.value
}
```

**Create a resource only when a condition is true:**

```hcl
resource "aws_cloudwatch_metric_alarm" "cpu" {
  count = var.enable_monitoring ? 1 : 0

  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
}
```

Reference it with `aws_cloudwatch_metric_alarm.cpu[0]`, or safely with `one(aws_cloudwatch_metric_alarm.cpu[*].arn)` (returns `null` when not created).

**Conditional value:**

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
}
```

**`for` expressions:**

```hcl
locals {
  upper_names = [for name in ["alice", "bob"] : upper(name)]
  # ["ALICE", "BOB"]

  name_lengths = { for name in ["alice", "bob"] : name => length(name) }
  # { alice = 5, bob = 3 }

  prod_only = [for env in ["dev", "prod", "prod-eu"] : env if startswith(env, "prod")]
  # ["prod", "prod-eu"]
}
```

**`dynamic` blocks — generate repeated nested blocks:**

```hcl
variable "ingress_ports" {
  type    = list(number)
  default = [22, 80, 443]
}

resource "aws_security_group" "dynamic_example" {
  name = "dynamic-sg"

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

The same result with separate rule resources (preferred for security groups):

```hcl
resource "aws_security_group" "web" {
  name = "web-sg"
}

resource "aws_vpc_security_group_ingress_rule" "ports" {
  for_each = toset(["22", "80", "443"])

  security_group_id = aws_security_group.web.id
  ip_protocol       = "tcp"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  cidr_ipv4         = "0.0.0.0/0"
}
```

---

← [Locals](07-locals.md) · [Index](README.md) · [Data sources](09-data-sources.md) →
