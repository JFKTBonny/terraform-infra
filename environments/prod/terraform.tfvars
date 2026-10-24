aws_region          = "eu-south-1"
environment         = "prod"
project_name        = "myapp"
vpc_cidr            = "10.20.0.0/16"
public_subnet_cidrs = ["10.20.1.0/24", "10.20.2.0/24"]
availability_zones  = ["eu-south-1a", "eu-south-1b"]
instance_type       = "t3.small"

# No SSH access in prod
allowed_ssh_cidrs = []
