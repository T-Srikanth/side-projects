# side-projects
- [OpenOps deployment using Terraform](./openops/README.md): This talks about provisioning an ec2 instance on AWS and installing OpenOps on it using Terraform. Amazon SNS is used to notify once the installation is complete.
- [kubeadm K8S installation guide](./Install_K8S_using_kubeadm.md): This guide explains how to set up a Kubernetes v1.32 cluster using kubeadm, with containerd as the runtime and Flannel for CNI networking.
- [VPN setup guide](./VPN_setup_GCP-AWS.md): This guide explains how to set up a site-to-site VPN between a GCP VPC and an AWS VPC using Classic VPN on GCP and Site-to-Site VPN on AWS, enabling private network communication across clouds.
- [mitmproxy in WireGuard mode](./mitm_wg/README.md): This guide talks about setting up three Docker containers to route app traffic through a WireGuard VPN tunnel into a mitmproxy server before reaching the internet, enabling full traffic interception.
