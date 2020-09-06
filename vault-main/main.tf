provider "vault" {
  address      = var.address
  token        = var.token
  ca_cert_file = var.ca_cert_file
}

module "groups" {
  source = "./groups"
}

module "userpass" {
  source = "./userpass"
}

module "approle" {
  source = "./approle"

  groups = module.groups.groups
}