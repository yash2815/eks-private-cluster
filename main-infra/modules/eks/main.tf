resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = var.cluster_role_arn
  version  = "1.29"

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
  }


 enabled_cluster_log_types = var.enable_cluster_logs ? [
  "api",
  "audit",
  "authenticator",
  "controllerManager",
  "scheduler"
] : []


  tags = {
    Name = var.name
  }

}

 resource "aws_security_group_rule" "allow_bastion_to_eks" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  source_security_group_id = var.bastion_sg_id
  description              = "Allow Bastion Host to access EKS API Server"
}
 


