# Copyright 2024 The MathWorks, Inc.

# Output definitions for the Compute Instance module

output "instance_name" {
  description = "The name of the created instance."
  value       = google_compute_instance.vm.name
}

output "instance_zone" {
  description = "The zone of the created instance."
  value       = google_compute_instance.vm.zone
}

output "instance_tags" {
  description = "The tags assigned to the created instance."
  value       = google_compute_instance.vm.tags
}

# Output VM public IP address
output "vm_public_ip" {
  description = "The public IP address of the VM instance."
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}