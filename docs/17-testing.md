# 17. Testing

`terraform test` (Terraform 1.6+) runs `*.tftest.hcl` files from the configuration folder or a `tests/` subfolder.

**modules/network/tests/network.tftest.hcl**

```hcl
variables {
  name                = "test"
  vpc_cidr            = "10.99.0.0/16"
  public_subnet_cidrs = ["10.99.1.0/24", "10.99.2.0/24"]
  availability_zones  = ["eu-south-1a", "eu-south-1b"]
}

mock_provider "aws" {}

run "creates_two_subnets" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Expected 2 public subnets."
  }
}

run "rejects_bad_cidr" {
  command = plan

  variables {
    vpc_cidr = "not-a-cidr"
  }

  expect_failures = [var.vpc_cidr]
}
```

```bash
cd modules/network
terraform init
terraform test
```

`mock_provider` fakes AWS, so tests run without credentials or cost. Remove it to test against real infrastructure (resources are created, then destroyed).

---

← [Built-in functions](16-functions.md) · [Index](README.md) · [Command cheat sheet](18-cli-cheat-sheet.md) →
