# Terraform VMware vSphere RHEL Automation

Automated provisioning of Red Hat Enterprise Linux (RHEL) 9.8 virtual machines on VMware vSphere using Terraform.

## Overview

This project demonstrates Infrastructure as Code (IaC) for provisioning RHEL virtual machines on VMware vSphere.

The current configuration creates:

* RHEL 9.8 VM
* 2 vCPUs
* 4 GB RAM
* 40 GB thin-provisioned disk
* VMXNET3 network adapter
* PVSCSI storage controller
* RHEL 9.8 DVD ISO
* VMware vSphere integration
* Offline Terraform provider support

### Architecture

```text
Terraform Host
      |
      | Terraform
      v
   vCenter
      |
      v
   ESXi Host
      |
      v
 RHEL 9.8 VM
```

---

## Technologies

| Technology              | Version / Configuration |
| ----------------------- | ----------------------- |
| Terraform               | 1.13.3                  |
| VMware vSphere Provider | ~> 2.12                 |
| VMware vSphere          | 8.x                     |
| Operating System        | RHEL 9.8                |
| Network Adapter         | VMXNET3                 |
| Storage Controller      | PVSCSI                  |
| Disk                    | 40 GB Thin              |
| Installation Media      | RHEL 9.8 DVD ISO        |

---

## VMware Environment

Example values:

```text
vCenter:   vcenter.example.com
Datacenter: Datacenter
Cluster:   Production-Cluster
Datastore: VM-Datastore
Network:   VM-Network
```

Replace these values with your own VMware environment.

The RHEL ISO should be available on the datastore:

```text
VM-Datastore/ISO/rhel-9.8-x86_64-dvd.iso
```

---

## VM Configuration

```text
VM Name:           terraform-test
Operating System:  RHEL 9.8
CPU:               2 vCPU
Memory:            4096 MB
Disk:              40 GB
Disk Type:         Thin Provisioned
Network Adapter:   VMXNET3
SCSI Controller:   PVSCSI
```

---

## Network Configuration

Example configuration:

```text
Hostname:  terraform-test
IP:        192.0.2.73
Netmask:   255.255.255.0
Gateway:   192.0.2.1
DNS:       192.0.2.53
```

> The `192.0.2.0/24` range is used for documentation only. Replace it with your actual network configuration.

---

## Project Structure

```text
terraform-vsphere-rhel-automation/
├── README.md
├── main.tf
├── .gitignore
└── .terraform.lock.hcl
```

Planned structure:

```text
terraform-vsphere-rhel-automation/
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── .gitignore
├── .terraform.lock.hcl
├── kickstart/
│   └── rhel9.ks
├── scripts/
│   └── setup-kickstart-server.sh
└── docs/
    └── architecture.md
```

---

## Configuration

Before deployment, update the following values in `main.tf` or provide them through `terraform.tfvars`:

```hcl
vsphere_server = "vcenter.example.com"

vm_name = "terraform-test"

vm_ip      = "192.0.2.73"
vm_netmask = "255.255.255.0"
vm_gateway = "192.0.2.1"
vm_dns     = "192.0.2.53"
```

Also update the VMware inventory values:

```hcl
data "vsphere_datacenter" "dc" {
  name = "Datacenter"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Production-Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = "VM-Datastore"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "VM-Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}
```

Update the RHEL ISO path if required:

```hcl
cdrom {
  datastore_id  = data.vsphere_datastore.datastore.id
  path          = "ISO/rhel-9.8-x86_64-dvd.iso"
  client_device = false
}
```

---

## Authentication

Create a local `terraform.tfvars` file:

```hcl
vsphere_server   = "vcenter.example.com"
vsphere_user     = "terraform-user"
vsphere_password = "CHANGE_ME"

vm_name = "terraform-test"

vm_ip      = "192.0.2.73"
vm_netmask = "255.255.255.0"
vm_gateway = "192.0.2.1"
vm_dns     = "192.0.2.53"
```

Never commit `terraform.tfvars` to GitHub.

---

## Offline Provider

For disconnected environments, the VMware provider can be installed from a local filesystem mirror.

Example:

```hcl
provider_installation {
  filesystem_mirror {
    path = "/opt/terraform/provider-mirror"

    include = [
      "registry.terraform.io/vmware/vsphere"
    ]
  }

  direct {
    exclude = [
      "registry.terraform.io/vmware/vsphere"
    ]
  }
}
```

Replace `/opt/terraform/provider-mirror` with your local provider mirror path.

---

## Requirements

* Terraform 1.13.x or newer
* VMware vSphere 8.x
* VMware vCenter Server
* VMware ESXi
* RHEL 9.8 DVD ISO
* VMware datastore
* VMware network / port group
* Required vCenter permissions
* VMware vSphere Terraform provider

---

## Deployment

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/terraform-vsphere-rhel-automation.git
cd terraform-vsphere-rhel-automation
```

Replace `YOUR_USERNAME` with your GitHub username.

### 2. Create variables

```bash
vim terraform.tfvars
```

Add your environment-specific values.

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Format the configuration

```bash
terraform fmt
```

### 5. Validate

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

### 6. Review the plan

```bash
terraform plan
```

Expected result for a clean deployment:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

### 7. Deploy

```bash
terraform apply
```

Confirm with:

```text
yes
```

---

## Current Installation Workflow

The current project provisions the VMware virtual machine and attaches the RHEL installation ISO.

```text
terraform apply
       |
       v
Create VMware VM
       |
       v
Attach RHEL 9.8 ISO
       |
       v
Boot RHEL Installer
       |
       v
Install RHEL
       |
       v
Reboot
       |
       v
RHEL VM
```

The RHEL installation is currently performed manually.

---

## Planned Kickstart Automation

The next stage is to automate the complete RHEL installation using Kickstart.

Target workflow:

```text
terraform apply
       |
       v
Create VMware VM
       |
       v
Attach RHEL ISO
       |
       v
Boot Installer
       |
       v
Kickstart
       |
       +-- Disk Partitioning
       +-- Hostname
       +-- Network
       +-- Users
       +-- Packages
       +-- SELinux
       +-- Firewall
       |
       v
Automatic Installation
       |
       v
Reboot
       |
       v
RHEL VM Ready
```

---

## Security

Do not commit sensitive or internal infrastructure information.

Never publish:

* vCenter passwords
* API tokens
* SSH private keys
* Internal IP addresses
* Internal DNS names
* Internal hostnames
* Internal domain names
* Production infrastructure details
* Terraform state containing sensitive information

The following files should remain local:

```text
terraform.tfvars
terraform.tfstate
terraform.tfstate.*
.terraform/
terraform-provider-mirror/
```

Recommended `.gitignore`:

```gitignore
.terraform/

*.tfstate
*.tfstate.*

terraform.tfvars
*.auto.tfvars

terraform-provider-mirror/
```

---

## Pre-Deployment Checklist

* [ ] vCenter address updated
* [ ] vCenter username configured
* [ ] vCenter password configured
* [ ] Datacenter verified
* [ ] Cluster verified
* [ ] Datastore verified
* [ ] Network verified
* [ ] RHEL ISO path verified
* [ ] VM name available
* [ ] VM IP available
* [ ] Gateway verified
* [ ] DNS verified
* [ ] Terraform provider available
* [ ] vCenter permissions verified

Then run:

```bash
terraform fmt
terraform validate
terraform plan
```

Review the plan before:

```bash
terraform apply
```

---

## Future Improvements

* [ ] Automated RHEL installation with Kickstart
* [ ] Automatic hostname configuration
* [ ] Automatic network configuration
* [ ] Automatic package installation
* [ ] SSH configuration
* [ ] SSH key authentication
* [ ] Non-root administrative user
* [ ] VMware Tools configuration
* [ ] Ansible integration
* [ ] CI/CD integration
* [ ] Automated VM validation
* [ ] Infrastructure testing
* [ ] Automated cleanup

---

## Learning Objectives

This project demonstrates:

* Terraform
* Infrastructure as Code
* VMware vSphere
* RHEL administration
* Linux networking
* VM provisioning
* Kickstart automation
* Offline infrastructure
* Git and GitHub
* DevOps automation
* Reproducible infrastructure

---

## Author

**Mohammad**

DevOps | Linux | Infrastructure Automation

---

## License

This project is intended for educational, laboratory, and demonstration purposes.

```
```

