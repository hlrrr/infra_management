<details><summary>AWS note</summary>
	
- recover default VPC:
	```
	aws ec2 create-default-subnet --availability-zone us-west-2a
	```
- 

</details>

---

<details><summary>k8s Note</summary>


- config for dualstack:
  ```
	vi kubeadm-config.yaml
	---
	apiVersion: kubeadm.k8s.io/v1beta3
	kind: ClusterConfiguration
	networking:
	  podSubnet: 10.244.0.0/16,fc00:10:244::/56
	  serviceSubnet: 10.96.0.0/16,fc00:10:96::/108
	---
	apiVersion: kubeadm.k8s.io/v1beta3
	kind: InitConfiguration
	localAPIEndpoint:
	  advertiseAddress: "192.168.10.10"
	  bindPort: 6443
	nodeRegistration:
	  kubeletExtraArgs:
	    node-ip: 192.168.10.10,2001:470:61bb:10::10

  	kubeadm init --config=kubeadm-config.yaml
  ```
  ```
  curl -OL https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

	vi kube-flannel.yml (net-conf.json)

  	"EnableIPv6": true,
  	"IPv6Network" : "fc00:10:244::/56"

	kubectl apply -f kube-flannel.yml
  	kubectl get all -n kube-flannel
	kubectl get pods -A
	kubectl describe node [hostname] | grep Taints
	kubectl taint node [hostname] node-role.kubernetes.io/control-plane:NoSchedule-
  ```
- need to reboot(?) before join
   
- prevent auto-upgrading
  ```
  sudo apt-mark hold kubeadm
  sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
  ```
  
- change hostname
  ```
  hostnamectl set-hostname [new_host_name]
  
  vi /etc/hosts
  ```
  
- disable swap
  ```
  swappff -a

  vi /etc/fstab
  ```
  
- container runtime config.
  ```
  containerd config default > /etc/containerd/config.toml

  vi /etc/containerd/config.toml

  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  	SystemdCgroup = true

  systemctl restart containerd
  ```
  
- packet forward config.
  ```
	  vi /etc/sysctl.d/99-sysctl.conf
	  
	  net.ipv4.ip_forward=1
	  net.ipv6.conf.all.forwarding=1
  
	  sysctl -p
  ```
  
> ```/var/lib/kubelet/config.yaml``` will be created after ```kubeadm init```
	
</details>

---

<details><summary>Ansible Note</summary>

- install community module
  ```
  ansible-galaxy collection install community.docker
  ```
- become sudo auth
  ```
  become: yes
  become_method: sudo
  become_user: root
  ```
- Remote host auth/permission problem
  ```
	/etc/ansible/ansible.cfg

	[privilege_escalation]
	become=True
	become_method=sudo
	become_user=root
	become_ask_pass=True
  ```
</details>

---

<details><summary>Proxmox Note</summary>

 - ubuntu VM(cloned) ip addr config.\
   mod ```/etc/netplan/[some-config.yaml]```\
   execute ```netplan apply``` / ```systemctl restart systemd-networkd```(optional)

- DNS setup\
  setup server via dnsmasq.\
  let LXCs use the DNS server.\
  change DNS on webUI or Use CLI CMD on promox host.
	```
	pct list
	pct set [CTID] --nameserver [IP addr]
	```

  > systemd config: fail.\
  NetworkManager config: fail \
  script after bootup: fail.\
  proxmox host config: fail.
---
- VLAN setup\
  On WebUI, make Vlan interface\
  Name it [linux bridge + .vlan tag]\
  Set IP addr. (no gateway)\
  ![image](https://github.com/hlrrr/infra/assets/74647150/f1f52ac1-37d1-4b24-8dba-798c171607b1)

  mod /etc/network/interfaces for NAT config on Vlan.\
  ```
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

---


- SSH setup\
```#PermitRootLogin prohibit-password```
</details>
