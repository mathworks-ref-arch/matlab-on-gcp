# Copyright 2024 The MathWorks, Inc.


# Either of these two will execute based on the "create_new_vpc" flag.

# Fetch existing VPC details if `existing_vpc_name` is provided
data "google_compute_network" "existing_vpc" {
  count = var.existing_vpc_name != "" ? 1 : 0
  name  = var.vpc_name
}

# Create new VPC if `existing_vpc_name` is not provided
resource "google_compute_network" "vpc_network" {
  count                   = var.existing_vpc_name == "" ? 1 : 0
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project
}