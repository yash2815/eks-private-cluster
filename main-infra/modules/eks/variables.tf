variable "name" {}
variable "cluster_role_arn" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "enable_cluster_logs" {
  description = "Enable logging for EKS cluster"
  type        = bool
  default     = false
}

variable "bastion_sg_id" {
  description = "Security Group ID of the Bastion Host"
  type        = string
}



