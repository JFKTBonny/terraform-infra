aws_region          = "eu-south-1"
environment         = "dev"
project_name        = "myapp"
vpc_cidr            = "10.10.0.0/16"
public_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]
availability_zones  = ["eu-south-1a", "eu-south-1b"]
instance_type       = "t3.micro"

# Replace with your own public IP (curl -s https://checkip.amazonaws.com)
allowed_ssh_cidrs = ["203.0.113.10/32"]
