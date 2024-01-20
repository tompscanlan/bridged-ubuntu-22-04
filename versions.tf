terraform {
  required_version = "1.6.5"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
  }
}

