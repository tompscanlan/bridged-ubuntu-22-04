# create a cloud-init cloud-config.
# NB this creates an iso image that will be used by the NoCloud cloud-init datasource.
# see https://github.com/dmacvicar/terraform-provider-libvirt/blob/v0.7.1/website/docs/r/cloudinit.html.markdown
# see journactl -u cloud-init
# see /run/cloud-init/*.log
# see https://cloudinit.readthedocs.io/en/latest/topics/examples.html#disk-setup
# see https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html#datasource-nocloud
# see https://github.com/dmacvicar/terraform-provider-libvirt/blob/v0.7.1/libvirt/cloudinit_def.go#L133-L162
resource "libvirt_cloudinit_disk" "cloudinit" {
  name           = "${var.prefix}_cloudinit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = var.pool
}
data "template_file" "network_config" {
  template = file("${path.module}/templates/netplan.yml.tpl")

  vars = {
    mac = var.mac
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user-data.yml.tpl")


  vars = {
    user           = var.user
    password_hash  = var.password_hash
    authorized_key = jsonencode(trimspace(file("~/.ssh/id_rsa.pub")))
    extra_runcmd   = join("\n", var.extra_runcmd != null ? var.extra_runcmd : [])
    extra_packages = join("\n", var.extra_packages != null ? var.extra_packages : [])
  }
}


resource "libvirt_volume" "ubuntu_22_04_amd64" {
  name   = "ubuntu_22_04"
  pool   = var.pool
  source = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  format = "qcow2"
}
# resource "libvirt_volume" "ubuntu_22_04_kvm" {
#   name   = "ubuntu_22_04"
#   pool   = var.pool
#   source = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"
#   format = "qcow2"
# }

resource "libvirt_volume" "root_disk" {
  name           = "${var.prefix}_root.img"
  base_volume_id = libvirt_volume.ubuntu_22_04_amd64.id
  pool           = var.pool
  format         = "qcow2"
  size           = var.main_disk_size * 1024 * 1024 * 1024
}

# a data disk.
resource "libvirt_volume" "data_disk" {
  name   = "${var.prefix}_data.img"
  format = "qcow2"
  size   = var.data_disk_size * 1024 * 1024 * 1024
  pool   = var.pool
}


# see https://github.com/dmacvicar/terraform-provider-libvirt/blob/v0.7.1/website/docs/r/domain.html.markdown
resource "libvirt_domain" "host" {
  name    = var.prefix
  machine = "q35"
  cpu {
    mode = "host-passthrough"
  }
  vcpu       = var.cpu
  memory     = var.memory
  qemu_agent = true
  cloudinit  = libvirt_cloudinit_disk.cloudinit.id
  boot_device {
    dev = ["hd","network"]
  }
  autostart = var.autostart

  xml {
    xslt = file("${path.module}/templates/libvirt-domain.xsl")
  }
  video {
    type = "qxl"
  }
  disk {
    volume_id = libvirt_volume.root_disk.id
    scsi      = true
  }
  disk {
    volume_id = libvirt_volume.data_disk.id
    scsi      = true
  }
  network_interface {
    bridge = var.bridge
    mac    = var.mac
    wait_for_lease = true
  }
  network_interface {
    bridge = "vmnet"
    wait_for_lease = true
  }
  provisioner "remote-exec" {
    inline = [
      <<-EOF
      set -x
      id
      uname -a
      cat /etc/os-release
      echo "machine-id is $(cat /etc/machine-id)"
      hostname --fqdn
      cat /etc/hosts
      sudo sfdisk -l
      lsblk -x KNAME -o KNAME,SIZE,TRAN,SUBSYSTEMS,FSTYPE,UUID,LABEL,MODEL,SERIAL
      mount | grep ^/dev
      df -h
      ip a
      EOF
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = self.network_interface[0].addresses[0] # see https://github.com/dmacvicar/terraform-provider-libvirt/issues/660
      private_key = file("~/.ssh/id_rsa")
    }
  }
  lifecycle {
    ignore_changes = [
      disk[0].wwn,
      disk[1].wwn,
    ]
  }

}
