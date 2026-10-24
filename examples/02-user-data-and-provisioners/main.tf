# Shows the three ways to configure a server, from preferred to last resort:
#   1. user_data (cloud-init template)   -> installs nginx at first boot
#   2. local-exec provisioner            -> writes an inventory file on your machine
#   3. file + remote-exec on terraform_data -> re-deploys index.html when it changes
# Uses the default VPC and local state. For learning only.

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# ---------------------------------------------------------------------------
# SSH key and security group
# ---------------------------------------------------------------------------

resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "HTTP from anywhere, SSH from my IP"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.my_ip_cidr
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ---------------------------------------------------------------------------
# 1. User data: cloud-init template, runs once at first boot
# ---------------------------------------------------------------------------

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = templatefile("${path.module}/templates/cloud-init.yaml.tftpl", {
    app_name    = var.project_name
    environment = var.environment
    packages    = ["nginx", "git", "htop"]
  })

  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required"
  }

  # -------------------------------------------------------------------------
  # 2. local-exec: runs on YOUR machine, once, after the instance is created
  # -------------------------------------------------------------------------
  provisioner "local-exec" {
    command = "printf '[web]\\n%s ansible_user=ubuntu\\n' ${self.public_ip} > inventory.ini"
  }

  # Destroy-time provisioner: runs before the instance is deleted
  provisioner "local-exec" {
    when       = destroy
    command    = "rm -f inventory.ini" # destroy-time: only self/count.index/each.key allowed
    on_failure = continue
  }

  tags = {
    Name        = "${var.project_name}-web"
    Environment = var.environment
  }
}

# ---------------------------------------------------------------------------
# 3. file + remote-exec on terraform_data: re-runs whenever index.html changes
# ---------------------------------------------------------------------------

resource "terraform_data" "deploy_site" {
  triggers_replace = [
    aws_instance.web.id,
    filemd5("${path.module}/files/index.html"),
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(pathexpand(var.ssh_private_key_path))
    host        = aws_instance.web.public_ip
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "${path.module}/files/index.html"
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait > /dev/null",
      "sudo mv /tmp/index.html /var/www/html/index.html",
      "sudo chown www-data:www-data /var/www/html/index.html",
      "echo 'Site deployed'",
    ]
  }
}
