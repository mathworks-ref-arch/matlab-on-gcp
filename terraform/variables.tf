# Copyright 2024 The MathWorks, Inc.

# Google Cloud Project Image used for booting the VM
variable "image_name" {
  description = "Pre-built image name"
  type        = string

  validation {
    condition     = var.image_name != ""
    error_message = "The image_name must not be empty. Enter the name of the image you created using Packer. This can be found in manifest.json having label artifact_id"
  }
}

# Google Cloud Project ID - A globally unique identifier for your project
variable "project_id" {
  description = "GCP ProjectID"
  type        = string

  validation {
    condition     = var.project_id != ""
    error_message = "The project_id must not be empty. Enter the name of the project ID"
  }
}

# Google Cloud region for resources
variable "region" {
  type        = string
  default     = "us-west1"
  description = "Enter cloud regions"
}

# Google Cloud zone for resources
variable "zone" {
  type        = string
  default     = "us-west1-a"
  description = "Add zone for cluster vms"
}

variable "machine_type" {
  type        = string
  default     = "e2-standard-8"
  description = "Select VM hardware such as 'e2-standard-4' , 'n2-standard-4', 'n2-standard-8'"
}

## Network
# Existing VPC Name as Input. If the value is empty, then a new VPC will be created
variable "existing_vpc_name" {
  type        = string
  description = "Provide the name of the existing vpc you would like to deploy into. Leave empty to create a new vpc."
}

# Change this to the range specific to your organization
variable "allow_client_ip" {
  type        = set(string)
  description = "Add IP Ranges that would connect/submit job"

  validation {
    condition     = length(var.allow_client_ip) > 0
    error_message = "The allow_client_ip variable must not be empty. This field should be formatted as <ip_address>/<mask>. E.g. [\"11.22.33.44/32\",\"44.55.66.77/32\"]"
  }
}

# Existing Subnet Name as Input. If this is set to a non-empty string, an existing subnet will be used.
variable "existing_subnet_name" {
  type        = string
  description = "Provide the name of the existing subnet you would like to deploy into. Leave empty to create a new subnet."
}

# Provide valid CIDR if creating a new Subnet
variable "subnet_ip_cidr_range" {
  type        = string
  default     = "10.0.0.0/20"
  description = "Assign CIDR if creating new subnet. Make sure any existing subnet within the considered VPC and network region does not have the same CIDR."
}

# Provide a tag for supporting globally unique naming convention of resources on GCS
variable "tag" {
  type        = string
  description = "A prefix to make resource names unique"
}

# Choose whether to have a static ip address across machine restarts.
variable "create_static_ip" {
  description = "Whether to create a static IP address for the VM"
  type        = bool
}

# Optional License Manager for MATLAB, specified as a string in the form <port>@<hostname>. If not specified, use online licensing.
variable "license_manager" {
  type        = string
  description = "License manager"
}

# Provide an optional inline shell command to run on machine launch.
variable "optional_user_command" {
  type        = string
  description = "Optional user command"
}

variable "labels" {
  type = map(string)
  description = "A map of labels to apply to resources."

  validation {
    condition     = contains(keys(var.labels), "owner") && var.labels["owner"] != ""
    error_message = "The 'owner' label must be set and cannot be empty."
  }
}