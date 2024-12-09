# Copyright 2024 The MathWorks, Inc.

# Allow SSH traffic
resource "google_compute_firewall" "allow-ports" {
  name          = "${var.firewall_name}"
  network       = var.existing_vpc_name != "" ? data.google_compute_network.existing_vpc[0].name : google_compute_network.vpc_network[0].name
  direction     = "INGRESS"
  target_tags   = ["allowed-ports"]
  source_ranges = toset(var.allow_client_ip)
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
}