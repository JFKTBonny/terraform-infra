variable "name" {
  description = "Name of the web server and its security group"
  type        = string
}

variable "vpc_id" {
  description = "VPC to place the security group in"
  type        = string
}

variable "subnet_id" {
  description = "Subnet to launch the instance in"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "root_volume_size" {
  description = "Root disk size in GiB"
  type        = number
  default     = 10
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed to SSH in. Empty list = no SSH access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Extra tags for all resources"
  type        = map(string)
  default     = {}
}
