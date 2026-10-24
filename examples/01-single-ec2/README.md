# Example 01 — Single EC2 web server

The smallest useful Terraform project: one Ubuntu instance running nginx in the default VPC.
Uses local state, so it is for learning only.

```bash
cd examples/01-single-ec2
terraform init
terraform plan
terraform apply
terraform output url
terraform destroy
```

Requires a default VPC in the chosen region.

Explained in [docs/05-first-project.md](../../docs/05-first-project.md).
