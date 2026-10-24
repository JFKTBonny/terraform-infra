# network module

Creates a VPC with public subnets, an internet gateway, and a public route table.

## Usage

```hcl
module "network" {
  source = "../../modules/network"

  name                = "myapp-dev"
  vpc_cidr            = "10.10.0.0/16"
  public_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]
  availability_zones  = ["eu-south-1a", "eu-south-1b"]
}
```

## Inputs

| Name | Type | Required | Description |
|---|---|---|---|
| `name` | string | yes | Name prefix for resources |
| `vpc_cidr` | string | yes | VPC CIDR block |
| `public_subnet_cidrs` | list(string) | yes | One CIDR per public subnet |
| `availability_zones` | list(string) | yes | One AZ per public subnet (same length as above) |
| `tags` | map(string) | no | Extra tags |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | VPC ID |
| `vpc_cidr` | VPC CIDR block |
| `public_subnet_ids` | Public subnet IDs |
