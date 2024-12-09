# Copyright 2024 The MathWorks, Inc.

# GCP project name
variable "project" {
  description = "ProjectID"
  default     = ""
}

# Tag to uniquely name resources
variable "tag" {
  description = "A prefix to make resource names unique"
  default     = ""
}

# Client IPs
# change this to the range specific to your organization
variable "allow_client_ip" {
  type        = set(string)
  default     = []
  description = "Add IP Ranges that would connect/submit job"
}

# vpc name
variable "vpc_name" {
  type        = string
  default     = ""
  description = "Name of the new VPC."
}

variable "firewall_name" {
  type        = string
  default     = ""
  description = "Name of the firewall."
}

variable "existing_vpc_name" {
  type        = string
  default     = ""
  description = "The name of an existing VPC passed from parent variables.tf"
}