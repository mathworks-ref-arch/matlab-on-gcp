# **MATLAB on Google Cloud Platform**

This repository shows how to build a Google® machine image for Linux® with MATLAB® and MATLAB toolboxes installed.

A HashiCorp® Packer template generates the machine image. The template is an HCL2 file that tells Packer which plugins (builders, provisioners, post-processors) to use, how to configure those plugins, and what order to run them in. For more information, see [Packer Templates](https://www.packer.io/docs/templates#packer-templates).

## Table of Contents
1. [Requirements](#requirements)
2. [Costs](#costs)
3. [Quick Build Instructions](#quick-build-instructions)
4. [Customize and Run Packer Build](#customize-and-run-packer-build)
    1. [Build Time Variables](#build-time-variables)
    2. [Customize Packer Build](#customize-packer-build)
    3. [Installation Scripts](#installation-scripts)
5. [Validate Packer Template](#validate-packer-template)
6. [Deploy Machine Image](#deploy-machine-image)
6. [Connect to Virtual Machine](#connect-to-virtual-machine)
7. [Help Make MATLAB Even Better](#help-make-matlab-even-better)
6. [Technical Support](#technical-support)


## **Requirements**

* A MATLAB license. For details, see [License Requirements for MATLAB on Cloud Platforms](https://www.mathworks.com/help/install/license/licensing-for-mathworks-products-running-on-the-cloud.html).
* [Google Cloud CLI](https://cloud.google.com/sdk/docs/install). To log in, use: `gcloud auth application-default login`
* [Google Cloud CLI](https://cloud.google.com/sdk/docs/install). To log in, use: `gcloud auth application-default login`
* [Google Cloud "Project ID"](https://cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin). To retrieve your Project ID, use: `gcloud config get-value project`
* [Packer 1.7.0. or later](https://www.packer.io/downloads).
* [Terraform 1.6.6 or later](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli).

## **Costs**
You are responsible for the cost of the GCP services used when you create cloud resources using this guide. Resource settings, such as virtual machine type, affect the cost of deployment. For cost estimates, see the pricing pages for each GCP service you will be using. Prices are subject to change.

## **Quick Build Instructions**
This section shows how to build the latest MATLAB machine image in your own GCP account. 

Pull the source code and navigate to the Packer folder:
```bash
git clone https://github.com/mathworks-ref-arch/matlab-on-gcp.git
cd matlab-on-gcp/packer/v1
```

Assign the correct values to the `PROJECT_ID` and `OWNER` variables in the file `variables.auto.pkrvars.hcl`.

Initialize Packer to install the required plugins.
You only need to do this once.
For more information, see [init command reference (Packer)](https://developer.hashicorp.com/packer/docs/commands/init).
```bash
packer init .
## OR
packer init build-gcp-matlab.pkr.hcl
```

Start the Packer build with the default settings:
```bash
packer build .
## OR you could also directly pass the values from cli
packer build -var="PROJECT_ID=unset" -var="OWNER=unset" build-gcp-matlab.pkr.hcl
```
Packer writes the output, including the ID of the generated machine image, to a `manifest.json` file when the build ends.
To use the built image with a MathWorks Terraform template, see [Deploy Machine Image](#deploy-machine-image).

To build a previous version of MATLAB, see [Customize MATLAB Release to Install](#customize-matlab-release-to-install)


## **Customize and Run Packer Build**
This section describes the complete Packer build process and the different options for starting the build.


### **Build-Time Variables**
The [Packer template](https://github.com/mathworks-ref-arch/matlab-on-gcp/tree/master/packer/v1/build-gcp-matlab.pkr.hcl)
supports these build-time variables:
| Variable Name | Default Value | Description |
|---|---|---|
| [`PRODUCTS`](#customize-products-to-install)| MATLAB and all available toolboxes | Products to install, specified as a list of product names separated by spaces. For example, `MATLAB Simulink Deep_Learning_Toolbox Parallel_Computing_Toolbox`.<br/>If no products are specified, the Packer build will install MATLAB with all available toolboxes. For more information, see [MATLAB Package Manager](https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md).|
| `BASE_IMAGE_FAMILY` |  ubuntu-2204-lts | The base image OS family. |
| `VM_LABELS` |{name="packer-builder", build="matlab-linux"} | Tags to add to the Packer build instance.|
| `IMAGE_LABELS` | {name="packer-build", build="matlab", type="matlab-on-gcp"} | Tags to add to the machine image.|

For a full list of the variables used in the build, see the description fields in the
[Packer template](https://github.com/mathworks-ref-arch/matlab-on-gcp/tree/master/packer/v1/build-gcp-matlab.pkr.hcl).



### **Customize Packer Build**
#### **Customize Products to Install**
Use the Packer build-time variable `PRODUCTS` to specify the list of products you want to install on the machine image. If `PRODUCTS` is unspecified, Packer will install MATLAB with all the available toolboxes.

For example, to install the latest version of MATLAB and Deep Learning Toolbox, run:
```bash
packer build -var "PRODUCTS=MATLAB Deep_Learning_Toolbox" build-gcp-matlab.pkr.hcl
```

#### **Customize MATLAB Release to Install**
To use an earlier MATLAB release, use one of the variable definition files in the [release-config](https://github.com/mathworks-ref-arch/matlab-on-gcp/tree/master/packer/v1/release-config) folder.
These are available for MATLAB R2023a and later.

For example, to install MATLAB R2023b and all available toolboxes, run:
```bash
packer build -var-file="variables.auto.pkrvars.hcl" -var-file="release-config/R2023b.pkrvars.hcl" build-gcp-matlab.pkr.hcl
```
You can also combine command line variables. For example, to install MATLAB R2023b and only the Parallel Computing Toolbox, run:
```bash
packer build -var-file="variables.auto.pkrvars.hcl" -var-file="release-config/R2023b.pkrvars.hcl" -var="PRODUCTS=MATLAB Parallel_Computing_Toolbox" build-gcp-matlab.pkr.hcl
```
Launch the customized image using the corresponding Terraform Template.
For instructions using Terraform Templates, see the Deployment Steps
section in [MATLAB on Google Cloud Platform](https://github.com/mathworks-ref-arch/matlab-on-gcp).
#### **Customize Multiple Variables**
You can override default variable values in a separate [Variable Definition File](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/variables#standard-variable-definitions-files).

For example, to generate a machine image with the latest MATLAB, the Deep Learning and Parallel Computing toolboxes, and a different machine type, create a variable definition file named `custom-variables.pkrvars.hcl` containing these variable definitions.
```
MACHINE_TYPE    = "e2-highcpu-8"
PRODUCTS        = "MATLAB Deep_Learning_Toolbox Parallel_Computing_Toolbox"
```

To specify a MATLAB release using a variable definition file, modify the variable definition file
in the [release-config](https://github.com/mathworks-ref-arch/matlab-on-gcp/tree/master/packer/v1/release-config)
folder corresponding to the desired release.

Save the variable definition file and include it in the Packer build command.
```bash
packer build -var-file="custom-variables.pkrvars.hcl" build-gcp-matlab.pkr.hcl
```

### **Installation Scripts**
The Packer build executes scripts on the image builder instance during the build.
These scripts perform tasks such as
installing tools needed by the build,
installing MATLAB and toolboxes on the image using [MATLAB Package Manager](https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/MPM.md),
and cleaning up build leftovers (including bash history).

For the full list of scripts that the Packer build executes during the build, see the `BUILD_SCRIPTS` parameter in the
[Packer template](https://github.com/mathworks-ref-arch/matlab-on-gcp/tree/master/packer/v1/build-gcp-matlab.pkr.hcl).

In addition to the build scripts above, the Packer build copies further scripts to the machine image,
to be used during startup and at runtime. These scripts perform tasks such as setting up RDP, warming up MATLAB, and other utility tasks.

For the full list of startup scripts, see the `STARTUP_SCRIPTS` parameters in the
[Packer template](https://github.com/mathworks-ref-arch/matlab-on-gcp/tree/master/packer/v1/build-gcp-matlab.pkr.hcl).


## **Deploy Machine Image**
When the build finishes, Packer writes
the output to a `manifest.json` file, which contains these fields:
```json
{
  "builds": [
    {
      "name":,
      "builder_type": ,
      "build_time": ,
      "files": ,
      "artifact_id": ,
      "packer_run_uuid": ,
      "custom_data": {
        "build_scripts": ,
        "release": ,
        "specified_products":
      }
    }
  ],
  "last_run_uuid": ""
}
```

The `artifact_id` section shows the ID of the machine image generated by the most recent Packer build. Update the `image_name` in `terraform/terraform.tfvars` with the `artifact_id`.

Following the successful build, the new GCP image can be found in the console output or by using the following URL. Replace the value for `project_id` in `terraform/terraform.tfvars`.

    https://console.cloud.google.com/compute/images?tab=images&project=<PROJECT_ID>

The Terraform templates provided by MathWorks require you to run a [Packer build](#build-a-vhd) beforehand. 

Either use the [GCP Cloud shell](https://cloud.google.com/shell/docs/using-cloud-shell) or install Terraform locally. If you are using GCP with Terraform for the first time, you might have to set your project in your environment. You can do this by running: 
```bash
gcloud config set project <PROJECT_ID>
```

Once you have completed the setup, you can run the following commands to add the necessary plugins  to the `.terraform` directory, and get a preview of the resources to be created: 
```bash
cd ../../terraform
terraform init
terraform plan
```

To spawn the resources, execute:
```bash
terraform apply
## OR you could also directly pass the values from cli
terraform apply -var image_name="matlab-linux-r2024b-xxxx" -var project_id="unset" -var 'labels={owner="unset", environment="dev"}'
```

Optionally, you can also override the default variables, either in `/terraform/terraform.tfvars`, or by directly providing the values inline. For example, to create a static IP address and use an existing VPC and subnet:

```bash
terraform plan \
    -var create_static_ip=true \
    -var existing_vpc_name="<existing-vpc>" \
    -var existing_subnet_name="<existing-subnet>"

terraform apply \
    -var create_static_ip=true \
    -var existing_vpc_name="<existing-vpc>" \
    -var existing_subnet_name="<existing-subnet>"
```

To delete the spawned resources, execute: 
```bash
terraform destroy
```

If you have customized the build, for example by removing or modifying one or more of the included scripts, the resulting machine image **might no longer be compatible** with the provided Terraform template.
In some cases you can restore compatibility by making corresponding modifications to the Terraform template.

### **Run-Time Variables**
You can configure the following variables in `/terraform/terraform.tfvars` before deployment.

| Variable Name | Default Value | Description |
|---|---|---|
| `labels.owner` * | _unset_ | Update the name of the owner to tag it to the image. |
| `project_id` * | _unset_ | Update the Google Cloud Project ID - A globally unique identifier for your project. |
| `image_name` * | _unset_ | Update the machine image name after the Packer build. This can be found in `manifest.json` having label `artifact_id` |
| `tag` | "matlab" | Use a unique prefix tag to distinguish multiple VMs. |
| `existing_vpc_name` | _unset_ | Existing VPC name. If empty, a new VPC will be created. |
| `existing_subnet_name` | _unset_ | Existing subnet name. If empty, a new subnet will be created. |
| `allow_client_ip` * | [] | Update with the specific client machine public IP address. E.g. [\"11.22.33.44/32\",\"44.55.66.77/32\"] |
| `create_static_ip` | false | Choose whether to have a static IP address across machine restarts. |
| `license_manager` | _unset_ | Optional License Manager for MATLAB, specified as `<port>@<hostname>`. If not specified, use online licensing. |
| `optional_user_command` | _unset_ | Provide an optional inline shell command to run on machine launch. |

For a full list of the variables used in the deployment, see the description fields in the [Terraform variables](https://github.com/mathworks-ref-arch/matlab-on-gcp/tree/master/terraform/terraform.tfvars) file.

Variables having * means they are mandatory.

## **Connect to Virtual Machine**
You can connect to the VM with either ssh or RDP. Refer the below table on how to use each protocol.

| Connection Protocol | Steps to use |
|---|---|
| ssh | - Look for the value of `ssh_command` in the output post your deployment. <br> - Connect using the gcloud ssh. Sample command `gcloud compute ssh instance-name --zone=us-west1-a` <br> - Optionally you could also create a new user by using format `gcloud compute ssh user@instance-name --zone=us-west1-a`. <br> - See [here](https://cloud.google.com/sdk/gcloud/reference/compute/ssh) for more information.   |
| RDP | - Follow the ssh steps and you must set the password for the user by running `sudo passwd <user-name>`. <br> - Use the user and password to login into the RDP. |

## **Tips and Troubleshooting**

- **Use remote backend to store state files:** It is recommended to use the remote backends to store the Terraform state file. Terraform provides backend configuration. See the commented lines in `main.tf` or [here](https://developer.hashicorp.com/terraform/language/settings/backends/gcs) for more information.

- **Install Support Packages:** To install specific support package(s), use Add-Ons manager. See [here](https://in.mathworks.com/help/matlab/matlab_env/get-add-ons.html).

- **Dry run Terraform:** Always use `terraform plan` to review changes before applying them. This helps in understanding the impact of the changes and prevents unintended actions.

- **Validate Packer Template:** To validate the syntax and configuration of a Packer template, use the `packer validate` command. This command also checks whether the provided input variables meet the custom validation rules defined by MathWorks. For more information, see [`validate` Command](https://www.packer.io/docs/commands/validate#validate-command).
You can also use command line interfaces provided by Packer to inspect and format the template. For more information, see [Packer Commands (CLI)](https://www.packer.io/docs/commands).

- **Debug Packer:** Utilize Packer's debug mode `packer build -debug` for a more interactive build process. This is especially useful for troubleshooting and understanding the build process.


## **Help Make MATLAB Even Better**
You can help improve MATLAB by providing user experience information on how you use MathWorks products. Your participation ensures that you are represented and helps us design better products.
To opt out of this service, remove the [mw_context_tag.sh](https://github.com/mathworks-ref-arch/matlab-on-gcp/tree/master/packer/v1/build/config/matlab/mw_context_tag.sh)
script under the `config` folder,
and the line in [install-matlab.sh](https://github.com/mathworks-ref-arch/matlab-on-gcp/tree/master/packer/v1/build/install-matlab.sh)
which moves `mw_context_tag.sh` to the image.

To learn more, see the documentation: [Help Make MATLAB Even Better - Frequently Asked Questions](https://www.mathworks.com/support/faq/user_experience_information_faq.html).

## **Technical Support**
To request assistance, or additional features, contact [MathWorks Technical Support](https://www.mathworks.com/support/contact_us.html).


----

Copyright 2024-2025 The MathWorks, Inc.

----
