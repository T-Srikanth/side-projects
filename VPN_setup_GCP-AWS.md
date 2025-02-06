# VPN setup GCP-AWS
**Objective**: Setup a VPN connection between private networks in GCP and AWS.
Network CIDR on GCP: 10.0.0.0/24
Network CIDR on AWS: 10.0.1.0/24
**Note**: This network configuration may result in additional cloud service charges.

## Prerequisites:
- GCP account
- AWS account

## Steps:

### On GCP:
- Create VPC network:
    - *Name*: gcp-vpc
    - *Subnet creation mode*: Custom
  <img src="/Assets/vpn_setup_ss/1.png">
- Subnets:
    - *Name*: gcp-subnet
    - *Region*: us-east1
    - *IP stack type*: IPv4
    - *IPv4 range*: 10.0.0.0/24
  <img src="/Assets/vpn_setup_ss/2.png">
- Firewall rules:
    - Add necessary firewall rules and click create
  <img src="/Assets/vpn_setup_ss/4.png">
- Create VPN connection(Classic VPN):
    - *Google Compute Engine VPN gateway*: gcp-vpn-gateway
    - *Network*: gcp-vpc
    - *Region*: us-east1
    - *IP address*: create new(reserves an external IP address for the gateway)
- Tunnels:
    - *Name*: gcp-aws-tunnel
    - *Remote peer IP address*: <tunnel outside IP address from AWS>
    - *IKE version*: IKEv1
    - *IKE pre-shared key*: <Generate and copy>
    - *Routing options*: Route-based
    - *Remote network IP ranges*: 10.0.1.0/24 (AWS network CIDR)

### On AWS:
- Create VPC:
    - *Name*: aws-vpc
    - *IPv4 CIDR*: 10.0.1.0/24
- Create subnet:
    - *VPC ID*: select aws-vpc
    - *Subnet name*: aws-subnet
    - *IPv4 subnet CIDR block*: 10.0.1.0/24
  <img src="/Assets/vpn_setup_ss/5.png">
- Create Internet Gateway[^1] and attach it to aws-vpc
- Update route table to route 0.0.0.0/0 traffic through the Internet Gateway
- Create Customer gateway:
    - *Name*: gcp-gateway
    - *IP address*: <get reserved external IP address of gateway from GCP>
  <img src="/Assets/vpn_setup_ss/6.png">
- Create Virtual private gateway:
    - *Name*: aws-gateway
    - Attach it to the aws-vpc
- Create Site-to-Site VPN connection:
    - *Name*: aws-gcp-vpn
    - *Target gateway type*: Virtual private gateway
    - *Virtual private gateway*: select aws-gateway
    - *Customer gateway*: Existing
    - *Customer gateway ID*: select gcp-gateway
    - *Routing options*: Static
    - *Static IP prefixes*: 10.0.0.0/24
  <img src="/Assets/vpn_setup_ss/7.png">
- Tunnel details:
    - Paste the pre-shared key copied from GCP
  <img src="/Assets/vpn_setup_ss/8.png">
- Add route rule for destination 10.0.0.0/24(GCP network CIDR) to use aws-gateway
- Allow ICMP traffic[^2] from 10.0.0.0/24(GCP network CIDR) in the security group.
- Check tunnel status[^3] on AWS and GCP.
<img src="/Assets/vpn_setup_ss/9.png">

[^1]: Internet gateway here is required if you want to connect to the instance from your local machine(via internet).
[^2]: For testing purpose you can allow all traffic from 10.0.0.0/24(GCP network CIDR)
[^3]: It might take some to establish the tunnel.