# EKS Private Cluster with Terraform

## ✅ Requirements
- Terraform >= 1.4.0
- AWS CLI
- kubectl

## 📦 Project Structure
- `state-mgmt/`: Remote backend configuration
- `main-infra/`: Infrastructure code and modules

## 🚀 Setup Instructions

### 1. Configure Remote Backend
```bash
cd state-mgmt
terraform init
terraform apply
```

### 2. Deploy Infrastructure
```bash
cd ../main-infra/env/dev
terraform init
terraform apply
```

### 3. Access Cluster
```bash
aws eks --region us-east-1 update-kubeconfig --name private-eks-cluster
```

### 4. Get Node Info
```bash
cd ../../scripts
chmod +x get-nodes.sh
./get-nodes.sh
```
