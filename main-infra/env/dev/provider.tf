terraform {
  backend "s3" {
    bucket         = "verantos-tf-state-backend-20250731123935193500000001"
    key            = "state/verantos-deploy.tfstate"
    region         = "us-east-1"
    dynamodb_table = "verantos-tf-state-dynamo-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.45.0"
    }
  }
}

provider "aws" {
  region = var.region
}


