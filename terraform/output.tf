# Copyright 2024 The MathWorks, Inc.

#Output instance_name
output "instance_name" {
  description = "The name of the created instance."
  value       = module.compute_instance.instance_name
}

# Output VM public IP address
output "vm_public_ip" {
  description = "The public IP address of the VM instance."
  value       = module.compute_instance.vm_public_ip
}

# Output matlab_vpc_network
output "matlab_vpc_network" {
  description = "The output of the module matlab_vpc_network"
  value       = module.matlab_vpc_network
}

# Output matlab_subnet
output "matlab_subnet" {
  description = "The output of the module matlab_subnet"
  value       = module.matlab_subnet
}

# gcloud compute ssh command
output "ssh_command" {
  description = "Set your desired user and password using gcloud ssh command"
  value       = "gcloud compute ssh ${module.compute_instance.instance_name} --zone=${var.zone}"
}

# Allowed client ip-address
output "allowed-client-ip" {
  description = "The list of allowed client-ip addresses"
  value       = join(", ", var.allow_client_ip)
}

# Informatary message for using the RDP
output "rdp-usage" {
  description = "Information before using the RDP"
  value       = "Info: Before using RDP, you must either set the password for the current user or create a new user with password."
}