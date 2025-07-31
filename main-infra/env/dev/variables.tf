variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "name" {
  description = "Base name for all resources"
  type        = string
}

# VPC & Subnet
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

# Public subnet for Bastion
variable "public_subnet_id" {
  description = "Public subnet ID where the Bastion host will be placed"
  type        = string
}

# Bastion host
variable "bastion_ami_id" {
  description = "AMI ID for Bastion EC2 instance"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for the Bastion host"
  type        = string
}

variable "bastion_key_name" {
  description = "Name of the SSH key pair used for Bastion"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "List of CIDR blocks allowed to SSH into Bastion"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs for Bastion or other public resources"
  type        = list(string)
}
