variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name used as a prefix for resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "One CIDR per public subnet"
  type        = list(string)
}

variable "availability_zones" {
  description = "One availability zone per public subnet"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed to SSH into the web server"
  type        = list(string)
  default     = []
}
