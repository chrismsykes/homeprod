// Look at identity and ssh authorized keys

// Proxmox Settings

insecure_skip_tls_verify   = "true"

// Removable Media Settings
iso_storage_pool           = "ISO"
iso_path                   = "ISO:iso"
iso_file                   = "ubuntu-24.04.1-live-server-amd64.iso"
unmount_iso                = "true"

// Guest Operating System Metadata
vm_guest_os_language       = "en_US"
vm_guest_os_keyboard       = "us"
vm_guest_os_timezone       = "geoip"



// Virtual Machine Hardware Settings
template_description       = "Ubuntu Server 24.04 LTS Template"
vm_guest_os_type           = "l26"
vm_guest_os_family         = "linux"
vm_guest_os_name           = "ubuntu"
vm_guest_os_version        = "24.04"
vm_guest_os_codename       = "noble"
vm_guest_os_qemu_agent     = "true"
vm_cloud_init              = "true"
vm_cloud_init_storage_pool = "local-lvm"
vm_scsi_controller         = "virtio-scsi-single"
vm_format                  = "raw"
// vm_id                      = "10000" // If commented out, will pick next available ID. If you want specific, uncomment and edit this.
vm_storage_pool            = "local-lvm"
vm_disk_type               = "scsi"
vm_cache_mode              = "writethrough"
vm_io_thread               = "true"
vm_cores                   = "2"
vm_sockets                 = "1"
vm_packet_queues           = "" // Currently set to var.vm_cores
vm_memory                  = "2048" // Needs to be in MB.
vm_disk_size               = "6G"
vm_cpu_type                = "host"
vm_machine                 = "q35"
vm_network_card            = "virtio"
vm_bridge                  = "vmbr0"
vm_firewall                = "false"
vm_vlan_tag                = "60"
vm_bios                    = "ovmf"

// Swap Settings
swap_size                  = "2G"

// Boot Settings
vm_boot_wait               = "5s"

// Communicator Settings
communicator_timeout       = "30m"
ssh_username               = "root"
ssh_clear_authorized_keys  = "true"

// Packer Settings
// http_bind_address = "192.168.50.100"
cidata_source         = "http"
http_bind_address          = "0.0.0.0"
http_port_min              = "8811"
http_port_max              = "8811"
