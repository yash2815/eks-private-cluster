output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "The private subnets created for the EKS cluster"
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  description = "EKS Cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "nodegroup_name" {
  description = "EKS Node Group name"
  value       = module.nodegroup.nodegroup_name
}

output "bastion_public_ip" {
  description = "Public IP address of the Bastion host"
  value       = module.bastion.bastion_public_ip
}

output "bastion_instance_id" {
  description = "EC2 Instance ID of the Bastion host"
  value       = module.bastion.bastion_instance_id
}
