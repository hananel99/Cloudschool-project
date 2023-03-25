
// define an s3 backend here
terraform {
  backend "s3" {
    bucket         = "hananel-cloudschool"
    key            = "terraform-workshop/terraform.tfstate"
    dynamodb_table = "tf-workshop-site-locks"
    region         = "us-east-1"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

module "vpc" {
  source = "../"

  environment     = "workshop-production"
  region          = "us-east-1"
  vpc_cidr =  "10.11.0.0/16"
  private_subnets = "10.11.0.0/20,10.11.16.0/20"  
  public_subnets  =   "10.11.32.0/20,10.11.48.0/20"
  azs = "us-east-1a,us-east-1b"

  enable_dns_support   = true
  enable_dns_hostnames = true

}

output "environment" {
  value = module.vpc.environment
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "admin_key_name" {
  value = module.vpc.admin_key_name
}


output "private_subnets" {
  value = module.vpc.private_subnets
}


output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "azs" {
  value = module.vpc.azs
}