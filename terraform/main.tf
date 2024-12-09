# Copyright 2024 The MathWorks, Inc.

# Provider and credentials
provider "google" {
  project     = local.project_id
  region      = var.region
  zone        = var.zone
}

# # Uncomment below if you want to use the Terraform backend configuration
# # Make sure the that the remote storage already exists.
# # See here to learn more: https://developer.hashicorp.com/terraform/language/settings/backends/gcs
#
# terraform {
#   backend "gcs" {
#     bucket  = "tf-state-prod"
#     prefix  = "terraform/state"
#   }
# }

# Create the local variables with computed values
locals {
  timestamp                     = formatdate("YYYYMMDDHHmmss", timestamp())
  new_vpc_name                  = "${var.tag}-vpc-${local.timestamp}"
  new_subnet_name               = "${var.tag}-subnet-${local.timestamp}"
  firewall_name                 = "${var.tag}-allow-ports-${local.timestamp}"
  vm_name                       = "${var.tag}-vm-${local.timestamp}"
  static_ip_name                = "${var.tag}-vm-static-ip-${local.timestamp}"
  metadata_startup_script_path  = "./local_scripts/metadata-startup-script.tftpl"
  project_id                    = var.project_id
  labels                        = merge(var.labels, { "tag" = var.tag })
}

# Create or reuse existing VPC
module "matlab_vpc_network" {
  source            = "./modules/vpc_network"
  tag               = var.tag
  existing_vpc_name = var.existing_vpc_name
  firewall_name     = local.firewall_name
  allow_client_ip   = var.allow_client_ip

  # If `existing_vpc_name` is an empty string, generate a new VPC name, otherwise use the existing VPC name.
  vpc_name = var.existing_vpc_name != "" ? var.existing_vpc_name : local.new_vpc_name
}

# Create or reuse existing Subnet
module "matlab_subnet" {
  source               = "./modules/subnet"
  tag                  = var.tag
  subnet_ip_cidr_range = var.subnet_ip_cidr_range
  region               = var.region
  network_id           = module.matlab_vpc_network.vpc_id
  existing_subnet_name = var.existing_subnet_name

  # If `existing_subnet_name` is an empty string, generate a new subnet name, otherwise use the existing subnet name.
  subnet_name = var.existing_subnet_name != "" ? var.existing_subnet_name : local.new_subnet_name
}

# Optionally create a static ip address
resource "google_compute_address" "static_ip" {
  count   = var.create_static_ip ? 1 : 0

  name    = local.static_ip_name
  region  = var.region
}

# Create a single Compute Engine instance
module "compute_instance" {
  source = "./modules/compute_instance"

  subnet_module         = module.matlab_subnet
  vm_name               = local.vm_name
  machine_type          = var.machine_type
  zone                  = var.zone
  image_name            = var.image_name
  subnet_name           = module.matlab_subnet.subnet_name
  create_static_ip      = var.create_static_ip
  static_ip_address     = var.create_static_ip ? google_compute_address.static_ip[0].address : null

  # The path of the startup script
  startup_script        = local.metadata_startup_script_path

  # The variables to pass for the startup script
  license_manager       = var.license_manager
  optional_user_command = var.optional_user_command
  labels                = local.labels
}
