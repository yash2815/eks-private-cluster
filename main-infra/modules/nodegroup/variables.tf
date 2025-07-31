variable "cluster_name" {}
variable "name" {}
variable "node_role_arn" {}
variable "private_subnet_ids" {
  type = list(string)
}
