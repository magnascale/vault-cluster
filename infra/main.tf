terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "binsabbar"
    workspaces {
      name = "vault-infra"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

resource "oci_identity_compartment" "compartment" {
  name           = "vault-cloud"
  description    = "compartment that holds PoCs resource for vault"
  compartment_id = var.tenancy_ocid
}

data "oci_identity_availability_domain" "ad_1" {
  compartment_id = oci_identity_compartment.compartment.id
  ad_number      = 1
}

module "network" {
  source = "./network"

  compartment_id = oci_identity_compartment.compartment.id
}

module "network_sg" {
  source = "./network-sg"

  compartment = oci_identity_compartment.compartment
  vnc         = module.network.network.vnc
  safe_ips    = var.safe_ips
}

module "instances" {
  source = "./instances"

  compartment         = oci_identity_compartment.compartment
  vnc                 = module.network.network.vnc
  availability_domain = data.oci_identity_availability_domain.ad_1
  instances           = local.instances
}

output "instances" {
  value = module.instances.instances
}