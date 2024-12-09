# Copyright 2024 The MathWorks, Inc.

# Main file for the Compute Instance module
resource "google_compute_instance" "vm" {
  depends_on   = [var.subnet_module]
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["allowed-ports"]

  boot_disk {
    initialize_params {
      image = var.image_name
    }
  }

  network_interface {
    subnetwork = var.subnet_name
    access_config {
      // Use the static IP if one is created, otherwise allocate an ephemeral IP
      nat_ip       = var.create_static_ip ? var.static_ip_address : null
      network_tier = "PREMIUM"
    }
  }

  # Using the custom startup script to configure the machine on first boot
  metadata_startup_script = templatefile("${var.startup_script}", {
    license_manager       = var.license_manager
    optional_user_command = var.optional_user_command
  })

  labels = var.labels
}