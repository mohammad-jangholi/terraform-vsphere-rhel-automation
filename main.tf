terraform {
  required_version = ">= 1.13.0"

  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.12"
    }
  }
}

provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = true
}

variable "vsphere_server" {
  type    = string
  default = "vcenter.example.com" # CHANGE REQUIRED
}

variable "vsphere_user" {
  type      = string
  sensitive = true
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

variable "vm_name" {
  type    = string
  default = "terraform-test" # CHANGE OPTIONAL
}

variable "vm_ip" {
  type    = string
  default = "192.0.2.73" # CHANGE REQUIRED
}

variable "vm_netmask" {
  type    = string
  default = "255.255.255.0" # CHANGE REQUIRED
}

variable "vm_gateway" {
  type    = string
  default = "192.0.2.1" # CHANGE REQUIRED
}

variable "vm_dns" {
  type    = string
  default = "192.0.2.53" # CHANGE REQUIRED
}

data "vsphere_datacenter" "dc" {
  name = "Datacenter" # CHANGE REQUIRED
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Production-Cluster" # CHANGE REQUIRED
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = "VM-Datastore" # CHANGE REQUIRED
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "VM-Network" # CHANGE REQUIRED
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2    # CHANGE OPTIONAL
  memory   = 4096 # CHANGE OPTIONAL

  guest_id  = "rhel9_64Guest"
  scsi_type = "pvscsi"

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 40 # CHANGE OPTIONAL
    thin_provisioned = true
  }

  cdrom {
    datastore_id  = data.vsphere_datastore.datastore.id
    path          = "ISO/rhel-9.8-x86_64-dvd.iso" # CHANGE REQUIRED
    client_device = false
  }

  boot_delay = 5000

  wait_for_guest_ip_timeout  = 0
  wait_for_guest_net_timeout = 0
}

output "vm_name" {
  value = vsphere_virtual_machine.vm.name
}

output "vm_ip" {
  value = var.vm_ip
}

output "ssh_command" {
  value = "ssh root@${var.vm_ip}"
}

