🚀 Secure Private EKS Cluster Provisioning with Terraform
📌 Assignment Overview
This project provisions a private Amazon EKS cluster using Terraform, ensures all nodes are in private subnets, and provides a Bastion host for secure access. A shell script is also included to list EKS nodes with their internal IPs.

🛠️ Tech Stack
AWS Services: VPC, EC2, EKS, IAM, NAT Gateway, Bastion Host

Terraform Version: ≥ 1.4.0

AWS Region: us-east-1

OS for Bastion Host: Ubuntu 22.04

Shell: Bash

Tools installed: kubectl, awscli

🔧 Folder Structure
eks-private-cluster/
├── main-infra/
│   ├── env/
│   │   └── dev/
│   │       ├── main.tf
│   │       ├── terraform.tfvars
│   │       ├── outputs.tf
│   │       └── provider.tf
│   └── modules/
│       ├── vpc/
│       ├── eks/
│       ├── nodegroup/
│       └── bastion/
├── get-nodes.sh
└── README.md
✅ Features Implemented
🔐 Private EKS Cluster
No public subnets used

EKS API endpoint is private-only

2 private subnets in different AZs (us-east-1a, us-east-1b)

EKS cluster and node groups created with Terraform

🔒 Secure Access via Bastion Host
Bastion in public subnet with Elastic IP

SSH access only via .pem key

Security Group Rule allows Bastion to access EKS API (port 443)

📜 Node Inspection Shell Script
get-nodes.sh uses kubectl to fetch:

Node names

Internal IPs

⚙️ Infrastructure Provisioning Steps
VPC Module

Created VPC with:

2 private subnets

2 public subnets

NAT Gateway in public subnet

Route tables and associations

EKS Module

Private EKS cluster with:

Private endpoint access only

IAM roles and permissions

Logging enabled

Cluster SG updated via aws_security_group_rule to allow access from Bastion

Node Group Module

Deployed managed node group in private subnets

Linked with the EKS cluster

Bastion Module

Ubuntu EC2 in public subnet

Security group with SSH access from 0.0.0.0/0

Public IP via Elastic IP

Outputs exposed:

Bastion Public IP

Bastion SG ID

Connectivity Fixes

Added NAT for outbound access from private subnets

Used Bastion to access internal cluster services

🖥️ get-nodes.sh Script
#!/bin/bash

echo "Fetching EKS nodes..."

kubectl get nodes -o wide | awk 'NR==1 { print "Node Name\tInternal IP" } NR>1 { print $1 "\t" $6 }'
🔑 Authentication & Access Instructions
SSH into Bastion:

chmod 400 eks-bastion-key.pem
ssh -i eks-bastion-key.pem ubuntu@<BASTION_PUBLIC_IP>
Install tools on Bastion:

sudo apt update && sudo apt install -y awscli curl unzip
curl -LO "https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/
Configure AWS:

aws configure
Fetch kubeconfig:

aws eks update-kubeconfig --name verantos-eks-cluster --region us-east-1
Run the script:

chmod +x get-nodes.sh
./get-nodes.sh
📄 IAM & Security Notes
EKS IAM Role: Attached with AmazonEKSClusterPolicy

Node Group Role: Attached with AmazonEKSWorkerNodePolicy, AmazonEC2ContainerRegistryReadOnly, AmazonEKS_CNI_Policy

Bastion SG: Allowed inbound SSH (port 22), outbound 0.0.0.0/0

EKS Cluster SG: Custom rule for allowing port 443 from Bastion SG

📝 Final Notes
No public exposure of the cluster

All infrastructure is provisioned via custom Terraform modules

Full control and security maintained across all resources
