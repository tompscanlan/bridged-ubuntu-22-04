#cloud-config
fqdn: example.test
manage_etc_hosts: true
users:
  - name: "${ user }"
    passwd: "${password_hash}"
    shell: /bin/bash
    lock_passwd: false
    ssh-authorized-keys:
      - ${authorized_key}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    ssh_import_id: 
        - gh:tompscanlan
disk_setup:
  /dev/sdb:
    table_type: mbr
    layout:
      - [100, 83]
    overwrite: false
fs_setup:
  - label: data
    device: /dev/sdb1
    filesystem: ext4
    overwrite: false
package_update: false
packages:
  - qemu-guest-agent
  - iperf3
  %{ for pkg in split("\n", extra_packages ) ~}
  %{ if pkg != "" ~}
- ${pkg}
  %{ endif ~}
  %{ endfor ~}

mounts:
  - [/dev/sdb1, /data, ext4, 'defaults,discard,nofail', '0', '2']
runcmd:
  - sudo systemctl enable qemu-guest-agent
  - sudo systemctl start qemu-guest-agent
  - sed -i '/vagrant insecure public key/d' /home/${user}/.ssh/authorized_keys
  %{ for cmd in split("\n", extra_runcmd ) ~}
- ${cmd}
  %{ endfor ~}
