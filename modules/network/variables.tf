variable "name" {
  description = "Name prefix for all network resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block, for example 10.10.0.0/16."
  }
}

variable "public_subnet_cidrs" {
  description = "One CIDR per public subnet"
  type        = list(string)
}

variable "availability_zones" {
  description = "One availability zone per public subnet"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) > 0
    error_message = "Provide at least one availability zone."
  }
}

variable "tags" {
  description = "Extra tags for all resources"
  type        = map(string)
  default     = {}
}
