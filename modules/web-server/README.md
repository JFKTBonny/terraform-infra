# web-server module

Creates an Ubuntu 24.04 EC2 instance running nginx, with its own security group.
IMDSv2 is required and the root disk is encrypted.

## Usage

```hcl
module "web" {
  source = "../../modules/web-server"

  name              = "myapp-dev-web"
  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.public_subnet_ids[0]
  instance_type     = "t3.micro"
  allowed_ssh_cidrs = ["203.0.113.10/32"]
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | string | — | Instance and security group name |
| `vpc_id` | string | — | VPC ID |
| `subnet_id` | string | — | Subnet ID |
| `instance_type` | string | `t3.micro` | EC2 instance type |
| `root_volume_size` | number | `10` | Root disk size (GiB) |
| `allowed_ssh_cidrs` | list(string) | `[]` | CIDRs allowed to SSH (empty = no SSH) |
| `tags` | map(string) | `{}` | Extra tags |

## Outputs

| Name | Description |
|---|---|
| `instance_id` | EC2 instance ID |
| `public_ip` | Public IP |
| `security_group_id` | Security group ID |
