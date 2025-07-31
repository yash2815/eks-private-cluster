output "bastion_instance_id" {
  value = aws_instance.bastion.id
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}

output "bastion_public_ip" {
  value = aws_eip.bastion_eip.public_ip
}

output "key_pair_name" {
  value = aws_key_pair.bastion_key.key_name
}


output "bastion_security_group_id" {
  description = "Security group ID attached to the Bastion host"
  value       = aws_security_group.bastion_sg.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

