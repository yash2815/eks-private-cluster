variable "key_name" {
  description = "Name of the SSH key pair to create"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for the Bastion host"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Bastion host"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID to associate the security group with"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block(s) allowed to SSH into Bastion"
  type        = list(string)  # ⚠️ use a list to support multiple CIDRs
}

variable "name" {
  description = "Name prefix for Bastion and related resources"
  type        = string
}

variable "public_key_path" {
  description = "Path to the local public key (optional if generating key with Terraform)"
  type        = string
  default     = "" # not used since we're generating keys via TLS
}
