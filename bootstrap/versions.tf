terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Bootstrap uses LOCAL state on purpose: it creates the bucket
  # that every other configuration uses as its backend.
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "terraform-bootstrap"
      ManagedBy = "terraform"
    }
  }
}
