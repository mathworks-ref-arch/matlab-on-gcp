# Copyright 2024 The MathWorks, Inc.

# Configure the default values before deployment

labels = {
    owner       = ""
    environment = "development"
}

# Update the project_id before deployment
project_id = ""

# Update the machine image name after the packer build
image_name = ""

# Use a unique prefix-tag to create multiple VMs.
tag = "matlab"

# Existing VPC and subnet Name as Input. If the value is empty, then a new VPC and subnet will be created
existing_vpc_name    = ""
existing_subnet_name = ""

# MathWorks recommends updating the specific client machine ip address. E.g. ["11.22.33.44/32","44.55.66.77/32"]
allow_client_ip = []

# Choose whether to have a static ip address across machine restarts.
create_static_ip = false

# Optional License Manager for MATLAB, specified as a string in the form <port>@<hostname>. If not specified, use online licensing.
license_manager = ""

# Provide an optional inline shell command to run on machine launch.
optional_user_command = ""
