# Copyright 2024 The MathWorks, Inc.

# Variable definitions for the Compute Instance module

variable "subnet_module" {
  description = "The subnet module dependency."
}

variable "vm_name" {
  description = "The name of the VM instance."
}

variable "machine_type" {
  description = "The machine type for the VM instance."
}

variable "zone" {
  description = "The zone in which to create the VM instance."
}

variable "image_name" {
  description = "The image to use for the VM instance."
}

variable "subnet_name" {
  description = "The name of the subnet to attach to the VM instance."
}

variable "create_static_ip" {
  description = "Whether to create a static IP for the VM instance."
}

variable "static_ip_address" {
  description = "The static IP address to assign to the VM instance."
}

variable "startup_script" {
  description = "The startup script to run on VM instance creation."
}

variable "license_manager" {
  description = "The license manager for the application."
}

variable "optional_user_command" {
  description = "An optional command to run on startup."
}

variable "labels" {
  description = "A map of labels to apply to the resource"
  type        = map(string)
}