# Copyright 2024 The MathWorks, Inc.

# Subnet in use
output "subnet_name" {
  description = "Subnet name"
  value       = var.existing_subnet_name != "" ? var.existing_subnet_name : google_compute_subnetwork.subnet[0].name
}

# Resource ID for Subnet
output "subnet_id" {
  description = "Network ID for the Subnet"
  value       = var.existing_subnet_name != "" ? data.google_compute_subnetwork.existing_subnet[0].id : google_compute_subnetwork.subnet[0].id
}
