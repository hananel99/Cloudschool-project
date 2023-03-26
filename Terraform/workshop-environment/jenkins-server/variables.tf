variable "cluster_name" {
	default = "jenkins-server"
}

variable "main-instance_local_ipv4" {
  description = "Main instance local ipv4"
  default = "10.11.45.30"
  
}
variable "main-instance_ssh_sg_id" {
  description = "Main-instance ssh security group id"
  default = "sg-0a8d63bcc40c3b697"
}

variable "instance_type" {
  description = "instance type for workshop-app instances"
  default = "t2.micro"
}

variable "ami" {
  description = "ami id for workshop-app instances"
  default = "ami-0557a15b87f6559cf"
}

variable "role" {
	default = "workshop-app-wrapper"
}

variable "terraform_bucket" {
  default = "hananel-cloudschool"
  description = <<EOS
S3 bucket with the remote state of the site module.
The site module is a required dependency of this module
EOS

}

variable "site_module_state_path" {
  default = "terraform/terraform.tfstate"
  description = <<EOS
S3 path to the remote state of the site module.
The site module is a required dependency of this module
EOS

}

variable region {
  default = "us-east-1"  
} 

variable "iam_cloudwatch_s3_profile_id" {
  description = "iam role id for cloudwatch and s3 full access"
  default = "arn:aws:iam::341146379129:role/CloudWatchS3Role"
  
}

variable "iam_cloudwatch_s3_profile_name" {
  description = "iam role name for cloudwatch and s3 full access"
  default = "CloudWatchS3Role"
}
