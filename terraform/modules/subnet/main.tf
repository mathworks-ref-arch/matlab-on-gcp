# Copyright 2024 The MathWorks, Inc.


# Either of these two will execute based on the "create_new_subnet" flag.

# Use existing subnet if `existing_subnet_name` is provided
data "google_compute_subnetwork" "existing_subnet" {
  count  = var.existing_subnet_name != "" ? 1 : 0
  name   = var.subnet_name
  region = var.region
}

# Creates a new Subnet if `existing_subnet_name` is not provided
resource "google_compute_subnetwork" "subnet" {
  count         = var.existing_subnet_name == "" ? 1 : 0
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip_cidr_range
  region        = var.region
  network       = var.network_id
}
