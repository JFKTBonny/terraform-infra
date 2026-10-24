locals {
  name = "${var.project_name}-${var.environment}"
}

module "network" {
  source = "../../modules/network"

  name                = local.name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
}

module "web" {
  source = "../../modules/web-server"

  name              = "${local.name}-web"
  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.public_subnet_ids[0]
  instance_type     = var.instance_type
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
}
