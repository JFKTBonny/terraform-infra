variable "aws_region" {
  description = "AWS region for the state bucket"
  type        = string
  default     = "eu-south-1"
}

variable "state_bucket_name" {
  description = "Globally unique name for the Terraform state bucket"
  type        = string
}

variable "github_owner" {
  description = "GitHub user or organization that owns the repository"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without the owner)"
  type        = string
}

variable "create_github_oidc_provider" {
  description = "Set to false if the GitHub OIDC provider already exists in this AWS account"
  type        = bool
  default     = true
}
