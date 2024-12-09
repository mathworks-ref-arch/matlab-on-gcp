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

# Region name
variable "region" {
  type        = string
  default     = ""
  description = "Name of the Region."
}

# Subnet name
variable "subnet_name" {
  type        = string
  default     = ""
  description = "Name of the Subnet."
}

variable "existing_subnet_name" {
  type        = string
  default     = ""
  description = "The name of an existing subnet to use."
}

# Provide valid CIDR if creating a new Subnet
variable "subnet_ip_cidr_range" {
  type        = string
  default     = "10.0.0.0/20"
  description = "Assign CIDR if creating new subnet. Make sure any other existing subnet within the considered VPC and network region does not have the same CIDR."
}

# VPC Network ID
variable "network_id" {
  type        = string
  default     = ""
  description = "The VPC network id."
}
