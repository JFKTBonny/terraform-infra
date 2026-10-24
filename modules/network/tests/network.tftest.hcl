# Run: cd modules/network && terraform init && terraform test
# mock_provider (Terraform 1.7+) fakes AWS: no credentials, no cost.

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
