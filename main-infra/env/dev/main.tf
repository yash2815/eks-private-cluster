module "vpc" {
  source               = "../../modules/vpc"
  cidr_block           = var.vpc_cidr
  availability_zones   = var.azs
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  name                 = var.name
  enable_nat_gateway   = true
  single_nat_gateway   = true
}



module "iam" {
  source = "../../modules/iam"
}

module "eks" {
  source              = "../../modules/eks"
  name                = var.name
  cluster_role_arn    = module.iam.cluster_role_arn
  private_subnet_ids  = module.vpc.private_subnet_ids
  enable_cluster_logs = true
  bastion_sg_id       = module.bastion.bastion_sg_id
}

module "nodegroup" {
  source             = "../../modules/nodegroup"
  name               = var.name
  cluster_name       = module.eks.cluster_name
  node_role_arn      = module.iam.node_role_arn
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "bastion" {
  source           = "../../modules/bastion"
  name             = var.name
  vpc_id           = module.vpc.vpc_id
  subnet_id        = var.public_subnet_id
  ami_id           = var.bastion_ami_id
  instance_type    = var.bastion_instance_type
  key_name         = var.bastion_key_name
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

