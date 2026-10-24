# 18. Command cheat sheet

```bash
# Setup
terraform init                      # initialize
terraform init -upgrade             # upgrade providers/modules within constraints
terraform init -reconfigure         # re-read backend config, ignore old
terraform init -migrate-state       # move state to a new backend

# Quality
terraform fmt -recursive            # format all files
terraform fmt -check -recursive     # check only (CI)
terraform validate                  # check syntax and types

# Planning
terraform plan                      # preview changes
terraform plan -out=tfplan          # save the plan
terraform plan -destroy             # preview a destroy
terraform plan -refresh-only        # show drift only
terraform plan -target=aws_instance.web   # one resource (emergencies only)

# Applying
terraform apply                     # plan + confirm + apply
terraform apply tfplan              # apply a saved plan (no prompt)
terraform apply -auto-approve       # skip confirmation (CI only)
terraform apply -replace=aws_instance.web   # force recreate
terraform apply -refresh-only       # accept drift into state

# Destroying
terraform destroy
terraform destroy -target=aws_instance.web

# Inspecting
terraform output
terraform output -json
terraform output -raw public_ip
terraform show
terraform show -json tfplan
terraform state list
terraform providers
terraform version
terraform graph | dot -Tpng > graph.png   # needs graphviz

# Testing
terraform test

# Workspaces
terraform workspace list
terraform workspace select dev

# Debugging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
```

**Lock providers for several platforms** (team on macOS + Linux CI):

```bash
terraform providers lock -platform=linux_amd64 -platform=darwin_arm64 -platform=darwin_amd64 -platform=windows_amd64
```

---

← [Testing](17-testing.md) · [Index](README.md) · [CI/CD](19-ci-cd.md) →
