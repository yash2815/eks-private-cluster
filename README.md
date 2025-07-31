🚀 Overview
This project demonstrates how to provision a secure and private Amazon EKS Cluster using Terraform with a Bastion Host, NAT Gateway, and Remote Backend for state management. You can SSH into the Bastion and use kubectl to interact with the EKS cluster.

📂 Project Structure
eks-private-cluster/
│
├── state-mgmt/                    # Remote backend configuration
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
│
├── main-infra/
│   ├── env/dev/                   # Root module to provision VPC, EKS, Bastion
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   ├── backend.tf
│   │   └── variables.tf
│   │
│   └── modules/
│       ├── vpc/
│       ├── eks/
│       ├── bastion/
│       └── nodegroup/
│
└── get-nodes.sh                   # Script to list node names and private IPs


✅ Requirements:
AWS CLI
Terraform ≥ 1.4.0
Kubectl
SSH access to Bastion (with PEM key)
IAM user/role with proper EKS, EC2, VPC, and S3 permissions


--------------------------------------------------------------------------------------------------------------------

🌐 AWS Region Used
Region: us-east-1

--------------------------------------------------------------------------------------------------------------------

🔐 Remote Backend Setup

Before provisioning infrastructure, we set up a Remote Backend using:

S3 Bucket: To store the Terraform state file centrally.
DynamoDB Table: To implement state locking and avoid race conditions.

📁 Location: state-mgmt/

🔍 Why use Remote Backend?
Centralized state sharing across teams
Version history for infrastructure
Locking prevents concurrent changes

Steps:

Create an S3 bucket and DynamoDB table manually (or via Terraform).
Configure the backend using backend.tf in main-infra/env/dev/.
Initialize Terraform using:

cd state-mgmt/
terraform init
terraform apply


--------------------------------------------------------------------------------------------------------------------



⚙️ Infrastructure Provisioning
📁 Location: main-infra/env/dev/

We used self-written Terraform modules for each resource category.

1. VPC Module:
   
      2 private subnets across different AZs

      2 public subnets (for Bastion + NAT Gateway)

Internet Gateway for public access

NAT Gateway for private subnet outbound access

Route tables for private & public subnets

📌 Why NAT Gateway?
EKS Node Groups must connect to Amazon EKS control plane and other AWS services (like container registry). Since our node groups are in private subnets, they need outbound internet access — which a NAT Gateway provides.


-----------

2. Bastion Module
Deployed in a public subnet

Key Pair generated automatically

Security group allowing SSH from 0.0.0.0/0

Elastic IP for public access

🔐 Used to access internal cluster resources like EKS via kubectl.

-----------

3. EKS Module
Private-only API endpoint (endpoint_public_access = false)

Subnet IDs from private subnets

Custom IAM roles for cluster and node group

Cluster log types enabled

-----------

4. Node Group Module
1 managed node group with 2 nodes in private subnets

Custom node IAM role attached

We have added an inbound rule to the EKS cluster SG to allow TCP port 443 from the Bastion SG.

📌 Done via Terraform like this:

resource "aws_security_group_rule" "allow_bastion_to_eks" {
  type                     = "ingress"
  from_port               = 443
  to_port                 = 443
  protocol                = "tcp"
  security_group_id       = <eks-cluster-sg-id>
  source_security_group_id = <bastion-sg-id>
  description             = "Allow Bastion Host to access EKS API Server"
}
Now kubectl works from Bastion for a private EKS cluster.

-----------

🖥️ Script: get-nodes.sh
Use this script from within the Bastion Host after setting up kubectl.

``` 
#!/bin/bash
echo "Fetching EKS Node Information..."
kubectl get nodes -o wide | awk 'NR==1 || /ip-/{print $1, $6}'

```

Sample Output:
Node Name                  Internal IP
ip-10-0-1-xx.ec2.internal  10.0.1.57
ip-10-0-2-yy.ec2.internal  10.0.2.89

-----------

🔑 Authenticating kubectl on Bastion
Install AWS CLI & kubectl on Bastion

Configure AWS credentials:
aws configure

Update kubeconfig:
aws eks --region us-east-1 update-kubeconfig --name verantos-eks-cluster

-----------

📤 Output Values After First Apply
After running terraform apply, these are returned:

Bastion instance ID and public IP

EKS cluster endpoint

Node group name

VPC ID

Subnet IDs

-----------

📌 Final Notes
This project was built from scratch without any starter template.

All modules were created manually (not re-used from Terraform Registry).

Terraform output values were used as input variables for later stages where needed.

GitHub repository was created from scratch and pushed after completion.
