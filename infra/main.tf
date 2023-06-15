provider "aws" {
  region  = var.region
  profile = var.profile
}

module "vpc" {
  source       = "./modules/vpc"
  ipv4_address = var.vpc_ipv4_address
  ipv4_mask    = var.vpc_ipv4_mask
}

module "network" {
  source = "./modules/network"
  vpc_id = module.vpc.vpc_id
}

module "vm" {
  source         = "./modules/vm"
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.network.subnet_id
  instance_type  = var.instance_type
  proxy_password = var.proxy_password
  proxy_username = var.proxy_username
}