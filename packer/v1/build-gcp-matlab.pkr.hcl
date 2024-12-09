# Copyright 2024 The MathWorks, Inc.

packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.1.6"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

# The following variables may have different value across releases and 
# it is recommended to modify them via the release-specific configuration file.
# To learn the release-specific values, visit the configuration file
# under /packer/v1/release-config/ folder.

variable "PROJECT_ID" {
  type    = string
  default = ""
  description = "You must provide a valid Google Cloud account Project ID before the build."

  validation {
    condition     = trimspace(var.PROJECT_ID) != ""
    error_message = "The PROJECT_ID variable must be set to a non-empty value. Update the value in the file 'variables.auto.pkrvars.hcl'."
  }
}

variable "OWNER" {
  type    = string
  default = ""
  description = "Optional name of the person or process who owns the image. This name appears in the label of the Packer VM and the final image."

  validation {
    condition     = trimspace(var.OWNER) != ""
    error_message = "The OWNER variable must be set to a non-empty value. Update the value in the file 'variables.auto.pkrvars.hcl'."
  }
}

variable "PRODUCTS" {
  type        = string
  default     = "5G_Toolbox AUTOSAR_Blockset Aerospace_Blockset Aerospace_Toolbox Antenna_Toolbox Audio_Toolbox Automated_Driving_Toolbox Bioinformatics_Toolbox Bluetooth_Toolbox C2000_Microcontroller_Blockset Communications_Toolbox Computer_Vision_Toolbox Control_System_Toolbox Curve_Fitting_Toolbox DDS_Blockset DSP_HDL_Toolbox DSP_System_Toolbox Database_Toolbox Datafeed_Toolbox Deep_Learning_HDL_Toolbox Deep_Learning_Toolbox Econometrics_Toolbox Embedded_Coder Filter_Design_HDL_Coder Financial_Instruments_Toolbox Financial_Toolbox Fixed-Point_Designer Fuzzy_Logic_Toolbox GPU_Coder Global_Optimization_Toolbox HDL_Coder HDL_Verifier Image_Acquisition_Toolbox Image_Processing_Toolbox Industrial_Communication_Toolbox Instrument_Control_Toolbox LTE_Toolbox Lidar_Toolbox MATLAB MATLAB_Coder MATLAB_Compiler MATLAB_Compiler_SDK MATLAB_Production_Server MATLAB_Report_Generator MATLAB_Test MATLAB_Web_App_Server Mapping_Toolbox Medical_Imaging_Toolbox Mixed-Signal_Blockset Model_Predictive_Control_Toolbox Motor_Control_Blockset Navigation_Toolbox Optimization_Toolbox Parallel_Computing_Toolbox Partial_Differential_Equation_Toolbox Phased_Array_System_Toolbox Powertrain_Blockset Predictive_Maintenance_Toolbox RF_Blockset RF_PCB_Toolbox RF_Toolbox ROS_Toolbox Radar_Toolbox Reinforcement_Learning_Toolbox Requirements_Toolbox Risk_Management_Toolbox Robotics_System_Toolbox Robust_Control_Toolbox Satellite_Communications_Toolbox Sensor_Fusion_and_Tracking_Toolbox SerDes_Toolbox Signal_Integrity_Toolbox Signal_Processing_Toolbox SimBiology SimEvents Simscape Simscape_Battery Simscape_Driveline Simscape_Electrical Simscape_Fluids Simscape_Multibody Simulink Simulink_3D_Animation Simulink_Check Simulink_Coder Simulink_Compiler Simulink_Control_Design Simulink_Coverage Simulink_Design_Optimization Simulink_Design_Verifier Simulink_Desktop_Real-Time Simulink_Fault_Analyzer Simulink_PLC_Coder Simulink_Real-Time Simulink_Report_Generator Simulink_Test SoC_Blockset Stateflow Statistics_and_Machine_Learning_Toolbox Symbolic_Math_Toolbox System_Composer System_Identification_Toolbox Text_Analytics_Toolbox UAV_Toolbox Vehicle_Dynamics_Blockset Vehicle_Network_Toolbox Vision_HDL_Toolbox WLAN_Toolbox Wavelet_Toolbox Wireless_HDL_Toolbox Wireless_Testbench"
  description = "Target products to install in the machine image, e.g. MATLAB SIMULINK."
}

variable "RELEASE" {
  type        = string
  default     = "R2024b"
  description = "Target MATLAB release to install in the machine image. Must start with \"R\"."

  validation {
    condition     = can(regex("^R20[0-9][0-9](a|b)(U[0-9])?$", var.RELEASE))
    error_message = "The RELEASE value must be a valid MATLAB release, starting with \"R\"."
  }
}

variable "MACHINE_TYPE" {
  type        = string
  default     = "e2-standard-8"
  description = "Name of the machine type."
}

variable "BUILT_IMAGE_NAME" {
  type        = string
  default     = "matlab-linux"
  description = "Name for the target image built using Packer."
}

variable "BASE_IMAGE_FAMILY" {
  type        = string
  default     = "ubuntu-2204-lts"
  description = "Family of the target image built using Packer."
}

variable "BUILD_SCRIPTS" {
  type        = list(string)
  default     = ["install-startup-scripts.sh", "install-dependencies.sh", "install-ubuntu-desktop.sh", "install-mate.sh", "install-matlab-dependencies-ubuntu.sh", "install-matlab.sh", "setup-startup-accelerator.sh", "generate-toolbox-cache.sh", "cleanup.sh"]
  description = "The list of installation scripts Packer uses to build the image."
}

variable "STARTUP_SCRIPTS" {
  type        = list(string)
  default     = [".env", "01_run-optional-user-command.sh", "10_setup-machine.sh", "20_setup-rdp.sh", "30_setup-matlab.sh", "40_warmup-matlab.sh"]
  description = "The list of startup scripts Packer copies to the remote machine image builder, which can be used during the CloudFormation Stack creation."
}

variable "RUNTIME_SCRIPTS" {
  type        = list(string)
  default     = ["set-newuser-permissions.sh"]
  description = "The list of runtime scripts Packer copies to the remote machine image builder, which can be used after the CloudFormation Stack creation."
}

variable "NVIDIA_DRIVER_VERSION" {
  type        = string
  default     = "535"
  description = "The version of target NVIDIA driver to install."
}

variable "NVIDIA_CUDA_TOOLKIT" {
  type        = string
  default     = "https://developer.download.nvidia.com/compute/cuda/12.2.2/local_installers/cuda_12.2.2_535.104.05_linux.run"
  description = "The URL to the NVIDIA CUDA Toolkit to install in the target machine image. "
}

variable "VM_LABELS" {
  type        = map(string)
  default     = {
        name  = "packer-builder"
        build = "matlab-linux"
      }
  description = "The labels Packer adds to the resulting machine image."
}

variable "IMAGE_LABELS" {
  type        = map(string)
  default     = {
        name  = "packer-build"
        build = "matlab"
        type  = "matlab-on-gcp-linux"
      }
  description = "The labels Packer adds to the resulting machine image."
}

variable "MANIFEST_OUTPUT_FILE" {
  type        = string
  default     = "manifest.json"
  description = "The name of the resulting manifest file."
}

variable "MATLAB_SOURCE_URL" {
  type        = string
  default     = ""
  description = "Optional URL from which to download a MATLAB and toolbox source file, for use with the mpm --source option"
}

# Set up local variables used by provisioners.
locals {
  timestamp               = regex_replace(timestamp(), "[- TZ:]", "")
  build_scripts           = [for s in var.BUILD_SCRIPTS : format("build/%s", s)]
  startup_scripts         = [for s in var.STARTUP_SCRIPTS : format("startup/%s", s)]
  runtime_scripts         = [for s in var.RUNTIME_SCRIPTS : format("runtime/%s", s)]
  project_id              = var.PROJECT_ID
  vm_labels_with_owner    = merge(
                              var.VM_LABELS,
                              { "owner" = var.OWNER },
                              { "matlab-release" = lower(var.RELEASE) }
                            )
  image_labels_with_owner = merge(
                              var.IMAGE_LABELS,
                              { "owner" = var.OWNER },
                              { "matlab-release" = lower(var.RELEASE) },
                              { "os" = var.BASE_IMAGE_FAMILY }
                            )
}

# Virtual Machine configuration that is used to build the machine image.
source "googlecompute" "Image_Builder" {
  project_id              = "${local.project_id}"
  disk_size               = "128"
  machine_type            = "${var.MACHINE_TYPE}"
  source_image_family     = "${var.BASE_IMAGE_FAMILY}"
  ssh_username            = "packer"
  zone                    = "us-central1-a"
  image_name              = "${var.BUILT_IMAGE_NAME}-${lower(var.RELEASE)}-${local.timestamp}"
  image_description       = "MATLAB from public packer."
  image_storage_locations = ["us-central1"]
  image_labels            = "${local.image_labels_with_owner}"
  labels                  = "${local.vm_labels_with_owner}"
}

# Build the machine image.
build {
  name = "matlab-linux-build"
  sources = ["source.googlecompute.Image_Builder"]

  provisioner "shell-local" {
    inline = [
      "echo Starting the build with the following configuration:",
      "echo MATLAB Version: ${var.RELEASE}",
      "echo PROJECT_ID: ${var.PROJECT_ID}",
      "echo BASE_IMAGE_FAMILY: ${var.BASE_IMAGE_FAMILY}"
    ]
  }
  
  provisioner "shell" {
    inline = ["mkdir /tmp/startup"]
  }

  provisioner "shell" {
    inline = ["mkdir /tmp/runtime"]
  }

  provisioner "file" {
    destination = "/var/tmp/"
    source      = "build/config"
  }

  provisioner "file" {
    destination = "/tmp/startup/"
    sources     = "${local.startup_scripts}"
  }

  provisioner "file" {
    destination = "/tmp/runtime/"
    sources     = "${local.runtime_scripts}"
  }

  provisioner "shell" {
    environment_vars = [
      "RELEASE=${var.RELEASE}",
      "PRODUCTS=${var.PRODUCTS}",
      "NVIDIA_DRIVER_VERSION=${var.NVIDIA_DRIVER_VERSION}",
      "NVIDIA_CUDA_TOOLKIT=${var.NVIDIA_CUDA_TOOLKIT}",
      "MATLAB_SOURCE_URL=${var.MATLAB_SOURCE_URL}",
      "MATLAB_ROOT=/usr/local/matlab"
    ]
    expect_disconnect = true
    scripts           = "${local.build_scripts}"
  }

  post-processor "manifest" {
    output     = "${var.MANIFEST_OUTPUT_FILE}"
    strip_path = true
    custom_data = {
      release            = "MATLAB ${var.RELEASE}"
      specified_products = "${var.PRODUCTS}"
      build_scripts      = join(", ", "${var.BUILD_SCRIPTS}")
    }
  }
}
