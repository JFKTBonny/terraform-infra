variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-south-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "demo02"
}

variable "environment" {
  description = "Shown on the web page and used in the template"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form, allowed to SSH (curl -s https://checkip.amazonaws.com)"
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0))
    error_message = "my_ip_cidr must be a CIDR, for example 203.0.113.10/32."
  }
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  description = "Path to your SSH private key (used by provisioners, never uploaded)"
  type        = string
  default     = "~/.ssh/id_ed25519"
}
