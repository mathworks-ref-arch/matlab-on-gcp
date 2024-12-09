# Copyright 2024 The MathWorks, Inc.

# VPC Network in use
output "vpc_network" {
  description = "Network name for the VPC"
  value       = var.existing_vpc_name != "" ? var.existing_vpc_name : google_compute_network.vpc_network[0].name
}

# Resource ID for VPC
output "vpc_id" {
  description = "Network ID for the VPC"
  value       = var.existing_vpc_name != "" ? data.google_compute_network.existing_vpc[0].id : google_compute_network.vpc_network[0].id
}