
output "ip" {
  value = length(libvirt_domain.host.network_interface[0].addresses) > 0 ? libvirt_domain.host.network_interface[0].addresses[0] : ""
}