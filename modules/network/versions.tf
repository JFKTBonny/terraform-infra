# Modules declare which providers they need, but never configure them.
# Provider and backend blocks live only in environments/*.

terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
