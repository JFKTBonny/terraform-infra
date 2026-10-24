# Example 02 — User data and provisioners

One Ubuntu web server configured three ways:

| Step | Technique | What it does |
|---|---|---|
| 1 | `user_data` + `templatefile()` (cloud-init) | Installs nginx and packages at first boot |
| 2 | `local-exec` provisioner | Writes `inventory.ini` on your machine; deletes it on destroy |
| 3 | `file` + `remote-exec` on `terraform_data` | Uploads `files/index.html`, re-runs when the file changes |

Explained in [docs/14-user-data-and-provisioners.md](../../docs/14-user-data-and-provisioners.md).

## Requirements

- A default VPC in the region
- An SSH key pair:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

## Run

```bash
cd examples/02-user-data-and-provisioners
terraform init
terraform apply -var="my_ip_cidr=$(curl -s https://checkip.amazonaws.com)/32"
terraform output url
cat inventory.ini
```

## See a provisioner re-run

```bash
echo "<h1>Version 2</h1>" > files/index.html
terraform apply -var="my_ip_cidr=$(curl -s https://checkip.amazonaws.com)/32"
```

Only `terraform_data.deploy_site` is replaced; the instance stays.

Force a re-run without changing anything:

```bash
terraform apply -replace=terraform_data.deploy_site -var="my_ip_cidr=$(curl -s https://checkip.amazonaws.com)/32"
```

## Debug user data on the server

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@$(terraform output -raw public_ip)
sudo cloud-init status --long
sudo cat /var/log/cloud-init-output.log
cat /etc/app/info
```

## Clean up

```bash
terraform destroy -var="my_ip_cidr=$(curl -s https://checkip.amazonaws.com)/32"
```
