region = "us-east-1"
name   = "verantos-eks-cluster"

vpc_cidr             = "10.0.0.0/16"
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
azs                  = ["us-east-1a", "us-east-1b"]

# Public subnet to host Bastion (manually created or imported)
public_subnet_id = "subnet-0c4367a6e38233306"

# Bastion configuration
bastion_ami_id        = "ami-053b0d53c279acc90"
bastion_instance_type = "t3.micro"
bastion_key_name      = "eks-bastion-key"
allowed_ssh_cidr      = ["0.0.0.0/0"] # Replace with your own IP or dev office IP
public_subnet_cidrs   = ["10.0.101.0/24", "10.0.102.0/24"]
