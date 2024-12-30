# windows VM driver troubles
 OS 설치중 디스크 인식, 설치 후 드라이버는 대부분 virtio-win.iso를 통해 해결 가능.
  
# ubuntu VM(cloned) ip addr config 
  ```
  /etc/netplan/[some-config.yaml]  

  netplan apply
  systemctl restart systemd-networkd
  ```

# DNS setup
  setup server via dnsmasq.\
  let LXCs use the DNS server.\
  change DNS on webUI or Use CLI CMD on promox host.
  ```
	pct list
	pct set [CTID] --nameserver [IP addr]
  ```  
  
  > 기본적으로 하이퍼바이저 호스트에서 설정에서 시작\
  systemd config: fail.\
  NetworkManager config: fail \
  script after bootup: fail.\
  proxmox host config: fail.

# VLAN setup
  On WebUI, make Vlan interface\
  Name it [linux bridge + .vlan tag]\
  Set IP addr. (no gateway)\
  ![image](https://github.com/hlrrr/infra/assets/74647150/f1f52ac1-37d1-4b24-8dba-798c171607b1)
  
  ```
 [/etc/network/interfaces for NAT config on Vlan]

  auto vmbr0
  iface vmbr0 inet static
          address 192.168.111.254/16
          gateway 192.168.0.1
          bridge-ports enp2s0
          bridge-stp off
          bridge-fd 0
          bridge-vlan-aware yes
          bridge-vids 2-4094
          post-up /sbin/ethtool -s enp2s0 wol g

  auto vmbr0.10
  iface vmbr0.10 inet static
          address 10.1.1.254/24

  # Post-up commands for routing and NAT
    post-up   echo 1 > /proc/sys/net/ipv4/ip_forward
    post-up ip route add 192.168.0.0/16 via 192.168.0.1 dev vmbr0
    post-up iptables -t nat -A POSTROUTING -s 10.1.1.0/24 -o vmbr0 -j MASQUERADE
    post-down iptables -t nat -D POSTROUTING -s 10.1.1.0/24 -o vmbr0 -j MASQUERADE
  ```
  
  On network tab of CT(or VM), add network the vlan device.\
  ![image](https://github.com/hlrrr/infra/assets/74647150/5d49ba03-dc28-408a-a225-f1b96d43225a)
