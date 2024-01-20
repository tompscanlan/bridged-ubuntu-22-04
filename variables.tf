variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
  default     = "bridged_ubuntu_22_04"
}

variable "cpu" {
  description = "How many CPUs to allocate to the VM"
  type        = number
  default     = 1
}

variable "memory" {
  description = "How much memory to allocate to the VM"
  type        = number
  default     = 1024
}

variable "pool" {
  description = "The name of the pool to use"
  type        = string
  default     = "default"
}

variable "user" {
  description = "The user to use for the ssh connection"
  type        = string
  default     = "ubuntu"
}

variable "password_hash" {
  description = "The password hash to use for login of the user"
  type        = string


}

variable "autostart" {
  description = "Whether to autostart the VM"
  type        = bool
  default     = false
}

variable "main_disk_size" {
  description = "The size of the main disk in GB"
  type        = number
  default     = 6
}

variable "data_disk_size" {
  description = "The size of the data disk in GB"
  type        = number
  default     = 6
}

variable "mac" {
  description = "The MAC address to use for the VM"
  type        = string
  default     = ""

}

variable "extra_runcmd" {
  description = "Extra commands to run in the cloud-init"
  type        = list(string)
  default     = []
}

variable "extra_packages" {
  description = "Extra packages to install"
  type        = list(string)
  default     = []
}

variable "bridge" {
  description = "The bridge to use for the VM"
  type        = string
  default     = "vmnet"
  
}