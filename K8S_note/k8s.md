# 공통작업
- set hostname
- swapoff
- setenforce 0
- module set and load
  ```
  cat <<EOF | tee /etc/modules-load.d/k8s.conf
  overlay
  br_netfilter
  EOF

  modprobe br_netfilter
  modprobe overlay
  (트러블 슈팅시 가장 먼저 시도해볼것.)
  ```
  
- 커널 파라미터 수정(패킷이 iptables policy 따르도록)
  ```
  cat <<EOF | tee /etc/sysctl.d/k8s.conf
  net.bridge.bridge-nf-call-iptables = 1
  net.bridge.bridge-nf-call-ip6tables = 1
  net.ipv4.ip_forward = 1
  EOF
  ```
- 커널 파라미터 로딩 및 적용
   ```
   sysctl --system
   ```
- 로드된 커널 모듈 확인
  ```
  lsmod | grep br_netfilter
  lsmod | grep overlay
  ```
- 수정된 커널 파라미터 확인
  ```
  sysctl  net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
  ```
  
- install containderd
  ```
  dnf install containerd
  ```
- containerd 기본 설정값 파일 생성 및 수정
  ```
  containerd config default > /etc/containerd/config.toml

  vi /etc/containerd/config.toml
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
	SystemdCgroup = true

  systemctl --now enable containerd
  ```

- installation \
  https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#k8s-install-1

# Controller

- initialize
  ```
  kubeadm init
  kubeadm init --ignore-preflight-errors=NumCPU,Mem (시스템 자원 부족시)
  ```
  
- cmd setup
  ```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf
  ```
  
- install network add-on
  ```
  open inbound ports if neeed (controller/worker)
  ex) edit instance security group to allow TCP 6783 and UDP 6783/6784 ports
  
  kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
  ```

- tokern re-issue
  ```
  kubeadm token create --print-join-command
  ```
  
# Worker
- kubeadm join

---

<details><summary>another setup</summary>

 config for dualstack:
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
  vi /etc/hosts

  hostnamectl set-hostname [new_host_name] 
  ```
  
- disable swap
  ```
  vi /etc/fstab
  
  swappff -a
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

    