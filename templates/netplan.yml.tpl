version: 2
ethernets:
  enp1s0:
    dhcp6: false
    %{if mac != "" }
    set-name: enp1s0
    match:
      macaddress: "${mac}"
    %{ endif }
    dhcp4: true
  enp2s0:
    dhcp4: true
#network:
#    ethernets:
#        enp1s0:
#            dhcp4: true
#            match:
#                macaddress: 52:54:00:86:ca:8d # 08:00:27:8e:52:52, 08:00:27:ed:4e:b5
#            set-name: enp1s0
#            addresses:
#              - 192.168.1.3/24
#            routes:
#              - to: default
#                via: 192.168.1.254
#            nameservers:
#              addresses:
#                - 192.168.1.254
#    version: 2