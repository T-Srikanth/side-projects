# Install K8S using kubeadm
Specs: **OS** **Image** - Ubuntu 24.04.1 LTS, **Architecture** - amd x86-64, **k8s version** - v1.32, **Container runtime** - containerd, **CNI** - flannel

### Instructions for kubernetes v1.32
- Download the public signing key and add Kubernetes apt repository
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

- Install kubelet kubeadm and kubectl  
```
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
kubeadm version
```
    
- Install container runtime
```
sudo apt-get update
sudo apt-get install -y containerd
```

- Check init system for kubelet
```
ps -p 1
```   

- Configure the systemd cgroup driver for containerd
```    
sudo mkdir -p /etc/containerd
sudo containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd 
```

- Enable kernel modules
```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

sudo modprobe br_netfilter
```

- Enable IPv4 packet forwarding
```    
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system
```

- Only on master node - Initialize control-plane node(change the apiserver ip address)
```
kubeadm init --apiserver-advertise-address 10.0.0.2 --pod-network-cidr "10.244.0.0/16" --upload-certs
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- Only on master node - Deploy a pod network(flannel in this example)
```    
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
``` 
- Join the cluster from worker nodes
<img src="/Assets/k8s_cluster_ss/1.png">