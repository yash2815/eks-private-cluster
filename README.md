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

```
cd state-mgmt/
terraform init
terraform apply
```


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

```

resource "aws_security_group_rule" "allow_bastion_to_eks" {
  type                     = "ingress"
  from_port               = 443
  to_port                 = 443
  protocol                = "tcp"
  security_group_id       = <eks-cluster-sg-id>
  source_security_group_id = <bastion-sg-id>
  description             = "Allow Bastion Host to access EKS API Server"
}

```
Now kubectl works from Bastion for a private EKS cluster.

--------------------------------------------------------------------------------------------------------------------


📊 Monitoring and Logging


We have enabled CloudWatch logging for the Amazon EKS control plane to improve observability and debugging.

✅ Enabled Log Types:
The following logs are streamed to Amazon CloudWatch Logs:

api
audit
authenticator
controllerManager
scheduler

🔧 Terraform Configuration:

```
This is configured in /modules/eks/main.tf as:

 enabled_cluster_log_types = var.enable_cluster_logs ? [
  "api",
  "audit",
  "authenticator",
  "controllerManager",
  "scheduler"
] : []

```

This helps track authentication issues, API calls, scheduler decisions, and other critical EKS events in CloudWatch.

--------------------------------------------------------------------------------------------------------------------

📁 IAM Configuration
Path: modules/iam/main.tf

To securely run and manage the Amazon EKS cluster and its worker nodes, we provisioned IAM roles and policies explicitly in the modules/iam/main.tf file.

This separation of IAM concerns ensures least-privilege access, supports logging, and allows EKS to manage the underlying AWS resources (e.g., EC2, networking) on our behalf.

🔹 1. eks-cluster-role
Path: modules/iam/main.tf

This IAM role is assumed by the EKS control plane. It grants Amazon EKS the necessary permissions to manage the Kubernetes control plane, including provisioning and interacting with AWS resources on our behalf (like ENIs, VPC resources, and CloudWatch logs).

```
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

```
Attached AWS-managed policy:

AmazonEKSClusterPolicy
Grants full access for managing EKS clusters and associated resources.

🔹 2. eks-node-role
Path: modules/iam/main.tf

This IAM role is assumed by EC2 instances that serve as EKS worker nodes. It allows nodes to pull container images, register with the cluster, and communicate with AWS services securely.

```
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

```
Attached AWS-managed policies:

AmazonEKSWorkerNodePolicy — for joining the EKS cluster.

AmazonEKS_CNI_Policy — for managing network interfaces.

AmazonEC2ContainerRegistryReadOnly — for pulling images from ECR.

🔹 3. Inline Policy for Logging (attached to eks-cluster-role)
To enable control plane logging to CloudWatch, we attach a custom inline policy to the eks-cluster-role. This ensures logs like API server, scheduler, authenticator, and controller manager are pushed to CloudWatch for observability and debugging.

```
resource "aws_iam_role_policy" "eks_logging_policy" {
  name = "eks-logging"
  role = aws_iam_role.eks_cluster_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      Resource = "*"
    }]
  })
}

```
This is required if you enable logging via the enabled_cluster_log_types attribute in your EKS configuration.

These IAM roles and policies are critical to the functioning of a secure and production-ready private EKS setup — enabling role-based access, secure EC2 interaction, and observability without over-privileging any component.

--------------------------------------------------------------------------------------------------------------------


🖥️ Script: get-nodes.sh
Now comes the final part to check the nodes status from our bastion ec2 server.

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
```
aws configure
```
Update kubeconfig:
```
aws eks --region us-east-1 update-kubeconfig --name verantos-eks-cluster
```

--------------------------------------------------------------------------------------------------------------------


📤 Output Values After First Apply (terraform apply):
After running terraform apply, these are returned:

Bastion instance ID and public IP

EKS cluster endpoint

Node group name

VPC ID

Subnet IDs

To check these values anytime after infra creation,
come back to the path: eks-private-cluster/main-infra/env/dev
Now execute following command:
```
terraform output
```

==> will show the output of all the resources created.

--------------------------------------------------------------------------------------------------------------------


🧾 Infrastructure Setup Summary

This project provisions a private Amazon EKS cluster from scratch using Terraform, emphasizing secure and production-ready architecture. The infrastructure is modular and follows best practices across networking, compute, IAM, and observability layers.

🔹 Key Components
VPC
A custom Virtual Private Cloud with:

2 public subnets (for Bastion host, NAT Gateway)

2 private subnets (for EKS cluster and nodes)

Proper route tables and internet access via NAT for private workloads

NAT Gateway
Required to allow instances in private subnets (like EKS nodes) to access the internet for pulling container images, etc.

Bastion Host
A secure jump box deployed in a public subnet with a key pair and restricted SSH access, allowing controlled access into the private subnets (including the EKS cluster).

EKS Cluster
A highly available, private Kubernetes control plane without public endpoint exposure. Communication is only allowed through the Bastion host or IAM-authenticated users.

EKS Node Group
Managed EC2-based worker nodes deployed in private subnets and linked to the EKS cluster via node IAM role, supporting the Kubernetes workloads.

IAM Roles & Policies
Fine-grained roles for both EKS control plane and nodes, along with custom inline policies to allow logging to CloudWatch and secure cluster operations.

CloudWatch Logging
Logging is enabled by attaching a custom policy to the cluster IAM role, granting EKS permissions to stream logs to Amazon CloudWatch.

📌 Workflow Summary
Remote backend configured with S3 and DynamoDB for storing and locking Terraform state.

Infrastructure provisioned via main-infra/env/dev using well-defined modules for vpc, eks, nodegroup, bastion, and iam.

All variable values centralized inside terraform.tfvars to allow environment-specific overrides.

Bastion's Security Group was added to EKS cluster's SG for seamless kubectl communication.

NAT Gateway ensures node group creation doesn't fail due to lack of internet access.

Auth configured to allow kubectl access via AWS CLI and aws-auth config map update.
