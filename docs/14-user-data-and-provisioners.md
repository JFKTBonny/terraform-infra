# 14. User data and provisioners

Terraform creates a server, but something still has to **configure** it (install packages, write config files, start services). There are four ways to do that:

| Method | Runs | Where | Use it for |
|---|---|---|---|
| **User data / cloud-init** | First boot only | On the instance, by the OS | Default choice: install packages, write files, start services |
| **Provisioners** (`local-exec`, `remote-exec`, `file`) | Once, when the resource is created (or destroyed) | Your machine / over SSH or WinRM | Last resort: steps user data can't do |
| **Config management** (Ansible, Chef…) | Whenever you run it | Over SSH | Ongoing configuration of long-lived servers |
| **Pre-baked image** (Packer AMI) | At image build time | Build pipeline | Fast, repeatable boots; immutable infrastructure |

> HashiCorp's guidance: **provisioners are a last resort.** Terraform cannot plan what they do, they don't re-run on changes, and a failure leaves the resource "tainted". Prefer user data or a pre-built image.

The full working example is in [`examples/02-user-data-and-provisioners`](../examples/02-user-data-and-provisioners).

## User data

`user_data` is a script (or cloud-init config) that the cloud provider passes to the instance. On Linux, **cloud-init** runs it as root on the **first boot only**.

**Inline script (heredoc):**

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    apt-get update -y
    apt-get install -y nginx
    echo "<h1>Hello from Terraform</h1>" > /var/www/html/index.html
    systemctl enable --now nginx
  EOF

  # Without this, changing user_data only updates the attribute;
  # the script does NOT run again on the existing instance.
  user_data_replace_on_change = true

  tags = {
    Name = "web"
  }
}
```

`<<-EOF` (with the dash) strips leading indentation, so the script can be indented inside the block. The `#!/bin/bash` line must be the first line of the result.

**Script from a file:**

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  user_data     = file("${path.module}/scripts/setup.sh")
}
```

**scripts/setup.sh**

```bash
#!/bin/bash
set -euxo pipefail
apt-get update -y
apt-get install -y nginx
systemctl enable --now nginx
```

**Script from a template (pass Terraform values in):**

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  user_data = templatefile("${path.module}/templates/setup.sh.tftpl", {
    app_name    = "myapp"
    environment = var.environment
    packages    = ["nginx", "git", "htop"]
  })

  user_data_replace_on_change = true
}
```

**templates/setup.sh.tftpl**

```bash
#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y ${join(" ", packages)}

# $${HOSTNAME} is escaped: Terraform outputs ${HOSTNAME} for bash to expand
echo "<h1>${app_name} (${environment}) on $${HOSTNAME}</h1>" > /var/www/html/index.html

%{ if environment == "prod" ~}
echo "Production mode" > /etc/app-mode
%{ else ~}
echo "Development mode" > /etc/app-mode
%{ endif ~}

systemctl enable --now nginx
```

Template rules:

| Syntax | Meaning |
|---|---|
| `${var}` | Terraform value inserted |
| `$${var}` | Literal `${var}` (for shell variables) |
| `%{ if cond ~} … %{ endif ~}` | Conditional |
| `%{ for x in list ~} … %{ endfor ~}` | Loop |
| `~` | Trims the newline next to the directive |

**cloud-init config (YAML instead of bash):**

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    app_name = "myapp"
    ssh_user = "deploy"
    ssh_key  = file(pathexpand("~/.ssh/id_ed25519.pub"))
  })

  user_data_replace_on_change = true
}
```

**templates/cloud-init.yaml.tftpl**

```yaml
#cloud-config
package_update: true
packages:
  - nginx
  - git

users:
  - default
  - name: ${ssh_user}
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${trimspace(ssh_key)}

write_files:
  - path: /var/www/html/index.html
    content: |
      <h1>${app_name}</h1>

runcmd:
  - systemctl enable --now nginx
```

`#cloud-config` must be the first line. cloud-init is declarative and runs the sections in a fixed order, which is easier to read than a long bash script.

**Combine several parts (cloudinit provider):**

```hcl
terraform {
  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3"
    }
  }
}

data "cloudinit_config" "web" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      package_update = true
      packages       = ["nginx"]
    })
  }

  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/scripts/setup.sh")
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  user_data     = data.cloudinit_config.web.rendered
}
```

**Launch templates (Auto Scaling) need base64:**

```hcl
resource "aws_launch_template" "web" {
  name_prefix   = "web-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  user_data = base64encode(templatefile("${path.module}/templates/setup.sh.tftpl", {
    app_name    = "myapp"
    environment = "prod"
    packages    = ["nginx"]
  }))
}
```

**Other clouds:**

| Cloud | Resource | Argument |
|---|---|---|
| AWS | `aws_instance` | `user_data` (plain text) |
| AWS | `aws_launch_template` | `user_data` (base64) |
| Azure | `azurerm_linux_virtual_machine` | `custom_data` (base64) |
| GCP | `google_compute_instance` | `metadata_startup_script` or `metadata = { user-data = … }` |

**Debugging user data on the instance:**

```bash
sudo cat /var/log/cloud-init-output.log
sudo cloud-init status --long
sudo cat /var/lib/cloud/instance/user-data.txt
curl -s http://localhost
```

**User data facts to remember:**
- Runs **once**, on first boot, as **root**. Not on reboot, not on `terraform apply` (unless the instance is replaced).
- AWS limit: **16 KB** (before base64). Bigger setups: download a script from S3, or use a custom AMI.
- `terraform apply` finishes **before** the script finishes. Nginx may need a minute or two.
- User data is visible to anyone who can describe the instance, and is stored in state. **No secrets in it**: fetch them at boot from Secrets Manager / SSM using an instance IAM role.

## Provisioners

Provisioners run commands **when a resource is created** (or destroyed). They are declared inside a resource block.

| Provisioner | Runs on | Typical use |
|---|---|---|
| `local-exec` | The machine running Terraform | Call a CLI, write an inventory file, trigger Ansible, notify a webhook |
| `remote-exec` | The new server, over SSH/WinRM | Run commands that must happen after boot, in order |
| `file` | Copies from local machine to the server | Upload a config file or directory |

### local-exec

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> inventory.txt"
  }
}
```

Use `self` to refer to the resource the provisioner belongs to (referencing `aws_instance.web` from inside itself is not allowed).

**Options: working directory, environment variables, interpreter:**

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  provisioner "local-exec" {
    working_dir = path.module
    interpreter = ["/bin/bash", "-c"]

    environment = {
      INSTANCE_ID = self.id
      PUBLIC_IP   = self.public_ip
    }

    command = <<-EOT
      echo "Created $INSTANCE_ID at $PUBLIC_IP"
      aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID"
      echo "Instance is healthy"
    EOT
  }
}
```

On Windows use `interpreter = ["PowerShell", "-Command"]`.

**Run Ansible after the server is up:**

```hcl
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  provisioner "local-exec" {
    command = <<-EOT
      ansible-playbook -i '${self.public_ip},' -u ubuntu --private-key ~/.ssh/id_ed25519 playbook.yml
    EOT

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}
```

### connection block (needed for remote-exec and file)

```hcl
resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web.id] # must allow port 22 from you

  connection {
    type        = "ssh"
    user        = "ubuntu" # Ubuntu AMIs: ubuntu | Amazon Linux: ec2-user
    private_key = file(pathexpand("~/.ssh/id_ed25519"))
    host        = self.public_ip
    timeout     = "5m"
  }
}
```

Create a key if you don't have one:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

> Prefer reading an existing key file over generating one with the `tls_private_key` resource: a generated private key is stored in plain text in the state.

### remote-exec

```hcl
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(pathexpand("~/.ssh/id_ed25519"))
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable --now nginx",
    ]
  }
}
```

`cloud-init status --wait` avoids clashing with user data (apt locks) that may still be running.

**Three forms of remote-exec** (each goes inside a resource, with a `connection` block):

```hcl
provisioner "remote-exec" {
  inline = ["echo one", "echo two"] # list of commands
}

provisioner "remote-exec" {
  script = "${path.module}/scripts/setup.sh" # one local script, uploaded and run
}

provisioner "remote-exec" {
  scripts = [
    "${path.module}/scripts/01-packages.sh",
    "${path.module}/scripts/02-app.sh",
  ] # several scripts, in order
}
```

### file

```hcl
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(pathexpand("~/.ssh/id_ed25519"))
    host        = self.public_ip
  }

  # Upload one file (to a path the SSH user can write)
  provisioner "file" {
    source      = "${path.module}/files/nginx.conf"
    destination = "/tmp/nginx.conf"
  }

  # Upload generated content
  provisioner "file" {
    content     = templatefile("${path.module}/templates/app.env.tftpl", { port = 8080 })
    destination = "/tmp/app.env"
  }

  # Upload a directory (no trailing slash on source = copies the folder itself)
  provisioner "file" {
    source      = "${path.module}/site"
    destination = "/tmp"
  }

  # Move files into place with sudo
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo apt-get install -y nginx",
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo cp -r /tmp/site/. /var/www/html/",
      "sudo systemctl restart nginx",
    ]
  }
}
```

Provisioners in one resource run **in the order written**.

### Destroy-time provisioners and failure handling

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  provisioner "local-exec" {
    command = "echo 'created ${self.id}' >> events.log"
  }

  provisioner "local-exec" {
    when       = destroy
    command    = "echo 'destroyed ${self.id}' >> events.log"
    on_failure = continue
  }
}
```

| Setting | Values | Meaning |
|---|---|---|
| `when` | `create` (default), `destroy` | When it runs |
| `on_failure` | `fail` (default), `continue` | `fail` marks the resource **tainted** (replaced on next apply) |

Destroy-time provisioners can only reference `self`, `count.index` and `each.key` (no variables or other resources). They do not run if you delete the resource block from the code: run `terraform destroy -target=<resource>` first, then remove the block.

### Re-running provisioners: `terraform_data`

Provisioners on a resource never run again after creation. To run commands **when something changes**, attach them to `terraform_data` (built in since Terraform 1.4; it replaces `null_resource`):

```hcl
resource "terraform_data" "deploy_app" {
  # Replaced (so provisioners re-run) whenever any of these values change
  triggers_replace = [
    aws_instance.web.id,
    filemd5("${path.module}/files/index.html"),
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(pathexpand("~/.ssh/id_ed25519"))
    host        = aws_instance.web.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/files/index.html"
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo mv /tmp/index.html /var/www/html/index.html",
    ]
  }
}
```

Edit `files/index.html` → next `terraform apply` re-uploads it, without replacing the instance.

**Force a re-run manually:**

```bash
terraform apply -replace=terraform_data.deploy_app
```

**Run something locally that doesn't belong to any resource:**

```hcl
resource "terraform_data" "generate_inventory" {
  triggers_replace = [aws_instance.web.public_ip]

  provisioner "local-exec" {
    command = "printf '[web]\\n%s\\n' ${aws_instance.web.public_ip} > inventory.ini"
  }
}
```

> For writing files, the `local_file` resource (`hashicorp/local` provider) is cleaner than `local-exec`, because Terraform tracks the file and shows it in the plan.

## Which one to use

- Installing packages and starting services → **user data / cloud-init**.
- Values from Terraform inside the script → **`templatefile()`** with user data.
- Many servers, fast scaling, no surprises at boot → **bake an AMI with Packer**, keep user data tiny.
- Re-applying app config to a long-lived server → **Ansible**, optionally triggered with `local-exec`.
- One step that must run from your machine (CLI call, webhook, file generation) → **`local-exec`** on `terraform_data`.
- `remote-exec` / `file` → only when nothing above fits; they need SSH open to the machine running Terraform (including CI).

---

← [Lifecycle, dependencies and validation](13-lifecycle-and-validation.md) · [Index](README.md) · [Import and refactoring](15-import-and-refactoring.md) →
