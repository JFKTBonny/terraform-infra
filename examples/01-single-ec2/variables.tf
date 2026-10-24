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
