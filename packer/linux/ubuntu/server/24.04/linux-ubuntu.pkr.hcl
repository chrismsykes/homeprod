// Ubuntu Server jammy
// Packer Template to create an Ubuntu Server (jammy) on Proxmox

packer {
  required_version = ">= 1.8.4"
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
    sshkey = {
      version = ">= 1.0.7"
      source = "github.com/ivoronin/sshkey"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.1.2"
    }
    git = {
      source  = "github.com/ethanmdavidson/git"
      version = ">= 0.6.3"
    }
  }
}

data "git-repository" "cwd" {
  path = "~/homeprod/"
}

locals {
  build_by                   = "Built by: HashiCorp Packer ${packer.version}"
  build_date                 = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  build_version              = lower(replace(trimspace(data.git-repository.cwd.head), "[^a-zA-Z0-9-]", ""))
  build_description          = "Version: ${local.build_version}\nBuilt on: ${local.build_date}\n${local.build_by}"
  manifest_date              = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  manifest_path              = "${path.cwd}/manifests/"
  manifest_output            = "${local.manifest_path}${local.manifest_date}.json"
  data_source_command = var.cidata_source == "http" ? "ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"" : "ds=\"nocloud\""
  vm_name                    = "${var.vm_guest_os_family}-${var.vm_guest_os_name}-${var.vm_guest_os_version}-${local.build_version}"
}



// Resource definitions for the VM Template
source "proxmox-iso" "ubuntu-server-nobel" {
 
    // Proxmox Connection Settings
    proxmox_url              = "https://${var.proxmox_host}:${var.proxmox_port}/api2/json"
    username                 = "${var.proxmox_api_token_id}"
    token                    = "${var.proxmox_api_token_secret}"
    // (Optional) Skip TLS Verification
    insecure_skip_tls_verify = "${var.insecure_skip_tls_verify}"
    
    // VM General Settings
    node                     = "${var.proxmox_node}" // add your proxmox node
    vm_id                    = "${var.vm_id}"
    vm_name                  = "${local.vm_name}"
    template_description     = "${var.template_description}"
    tags                     = "${var.vm_guest_os_family};${var.vm_guest_os_name}-${var.vm_guest_os_codename}"

    // VM OS ISO Settings
    boot_iso {
      type                   = "ide"
      iso_url                = "https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso"
      iso_checksum           = "sha256:e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
      iso_storage_pool       = "${var.iso_storage_pool}"
      unmount                = "${var.unmount_iso}"
      iso_download_pve       = true
  }

    // VM OS Settings
    os                       = "${var.vm_guest_os_type}"
    qemu_agent               = "${var.vm_guest_os_qemu_agent}"

    // VM Cloud-Init Settings
    cloud_init               = "${var.vm_cloud_init}"
    cloud_init_storage_pool  = "${var.vm_cloud_init_storage_pool}"

    // VM Hard Disk Settings
    scsi_controller          = "${var.vm_scsi_controller}"

    disks {
        disk_size = "${var.vm_disk_size}"
        format = "${var.vm_format}"
        storage_pool = "${var.vm_storage_pool}"
        type = "${var.vm_disk_type}"
        cache_mode = "${var.vm_cache_mode}"
        io_thread = "${var.vm_io_thread}"
    }
    efi_config {
      efi_storage_pool = "local-lvm"
      efi_type         = "4m"
    }

    // VM CPU Settings
    cores = "${var.vm_cores}"
    sockets = "${var.vm_sockets}"
    cpu_type = "${var.vm_cpu_type}"
    bios     = "ovmf"
    
    // VM Memory Settings
    memory = "${var.vm_memory}" 

    // VM Network Settings
    network_adapters {
        model = "${var.vm_network_card}" 
        bridge = "${var.vm_bridge}" 
        firewall = "${var.vm_firewall}" 
        vlan_tag = "${var.vm_vlan_tag}" 
        packet_queues = "${var.vm_cores}"
    }

    // Packer Boot Commands
    boot_command = [
    "<wait3s>c<wait3s>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
    ]

    // Packer Autoinstall Settings
    http_content = {
      "/meta-data" = file("./http/meta-data")
      "/user-data" = templatefile("./http/user-data.pkrtpl.hcl", {
      ansible_username         = var.ansible_username
      ansible_ssh_key          = var.ansible_ssh_key
      build_username           = var.build_username
      build_password_encrypted = var.build_password_encrypted
      build_ssh_key            = var.build_ssh_key
      vm_guest_os_language     = var.vm_guest_os_language
      vm_guest_os_keyboard     = var.vm_guest_os_keyboard
      vm_guest_os_timezone     = var.vm_guest_os_timezone
      })
    }
    // (Optional) Bind IP Address and Port
    http_bind_address          = "${var.http_bind_address}"
    http_port_min              = "${var.http_port_min}"
    http_port_max              = "${var.http_port_max}"
    ssh_username               = "${var.build_username}"
    ssh_private_key_file       = "${var.build_ssh_priv_key_file}"
    ssh_clear_authorized_keys  = "${var.ssh_clear_authorized_keys}"
    ssh_password               = "${var.build_password}"
    ssh_timeout                = "${var.communicator_timeout}"
}

// Build Definition to create the VM Template
build {
    sources = ["source.proxmox-iso.ubuntu-server-nobel"]

    provisioner "shell-local" {
  inline = ["echo 'Git Branch: ${data.git-repository.cwd.head}'"]
}


    // Provisioning the VM Template for Cloud-Init Integration in Proxmox. Needs to be first.
    provisioner "shell" {
      inline = [
        "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
      ]
    }

    // Transfer config files to template
    provisioner "file" {
      source = "files/configs"
      destination = "/tmp/configs/"
    }

    // Copying configs across
    provisioner "shell" {
      inline = [
        "sudo cp /tmp/configs/51unattended-upgrades /etc/apt/apt.conf.d/51unattended-upgrades",
        "sudo cp /tmp/configs/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg",
      ]
    }

    post-processor "manifest" {
    output     = local.manifest_output
    strip_path = true
    strip_time = true
    custom_data = {
      ansible_username         = var.ansible_username
      build_username           = var.build_username
      build_date               = local.build_date
      build_version            = local.build_version
      vm_cores                 = var.vm_cores
      vm_sockets               = var.vm_sockets
      vm_disk_size             = var.vm_disk_size
      vm_bios                  = var.vm_bios
      vm_guest_os_type         = var.vm_guest_os_type
      vm_memory                = var.vm_memory
      vm_network_card          = var.vm_network_card
      proxmox_node             = var.proxmox_node
    }
  }

    // Add additional provisioning scripts here
    // ...

    // Set up Cloud-Init on Proxmox as the builder can't yet do this.
    // Be aware there are some hardcoded overrides ("discard=on,iothread=1,ssd=1"). Make sure to update as you require.
}