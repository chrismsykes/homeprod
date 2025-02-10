/*
    DESCRIPTION:
    Ubuntu Server 22.04 LTS variables using the Packer Builder for Proxmox (proxmox-iso).
*/

//  BLOCK: variable
//  Defines the input variables.

variable "proxmox_api_token_id" {
  default = "${env("PROXMOX_API_TOKEN_ID")}"
}
variable "proxmox_api_token_secret" {
  default = "${env("PROXMOX_API_TOKEN_SECRET")}"
}
variable "proxmox_host" {
  default = "${env("PROXMOX_HOST")}"
}
variable "proxmox_port" {
  default = "${env("PROXMOX_PORT")}"
}
variable "insecure_skip_tls_verify" {
  type        = bool
  default     = true
}
variable "proxmox_node" {
  default = "${env("PROXMOX_NODE")}"
}
variable "build_username" {
  default = "${env("BUILD_USERNAME")}"
}
variable "build_password" {
  default = "${env("BUILD_PASSWORD")}"
}
variable "build_password_encrypted" {
  default = "${env("BUILD_PASSWORD_ENCRYPTED")}"
}
variable "build_ssh_key" {
  default = "${env("BUILD_SSH_PUB_KEY")}"
}
variable "ansible_ssh_key" {
  default = "${env("ANSIBLE_SSH_PUB_KEY")}"
}
variable "ansible_username" {
  default = "${env("ANSIBLE_USERNAME")}"
}
variable "iso_file" {}
variable "iso_storage_pool" {}
variable "cidata_source" {}
variable "unmount_iso" {
  type        = bool
  default     = true
}
variable "vm_guest_os_language" {}
variable "vm_guest_os_keyboard" {}
variable "vm_guest_os_timezone" {}
variable "template_description" {}
variable "vm_guest_os_family" {}
variable "vm_guest_os_name" {}
variable "vm_guest_os_version" {}
variable "vm_guest_os_codename" {}
variable "vm_guest_os_type" {}
variable "vm_guest_os_qemu_agent" {
  type        = bool
  default     = true
}
variable "vm_cloud_init" {
  type        = bool
  default     = true
}
variable "vm_cloud_init_storage_pool" {}
variable "vm_scsi_controller" {}
variable "vm_format" {}
variable "vm_id" {
  type        = string
  default     = null
}
variable "vm_storage_pool" {}
variable "vm_disk_type" {}
variable "vm_cache_mode" {}
variable "vm_io_thread" {
  type        = bool
  default     = true
}
variable "vm_packet_queues" {}
variable "vm_cores" {}
variable "vm_sockets" {}
variable "vm_memory" {}
variable "vm_disk_size" {}
variable "vm_cpu_type" {}
variable "vm_machine" {}
variable "vm_network_card" {}
variable "vm_bridge" {}
variable "vm_firewall" {
  type        = bool
  default     = false
}
variable "vm_vlan_tag"  {}
variable "iso_path" {}
variable "vm_boot_wait" {}
variable "communicator_timeout" {}
variable "http_bind_address" {}
variable "http_port_min" {}
variable "http_port_max" {}
variable "ssh_username" {}
variable "ssh_clear_authorized_keys" {}
variable "vm_bios" {}

// Swap
variable "swap_size" {}
variable "packer_data_source" {
  type         = string
  default      = "http"
}
