terraform {
  backend "s3" {
    bucket         = "hananel-cloudschool"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}


module "workshop-app" {
  source = "../workshop-app"
  main-instance_vault_sg_id = "${module.main-server.main-instance_vault_sg_id}"
  main-instance_consul_sg_id = "${module.main-server.main-instance_consul_sg_id}"
  main-instance_ssh_sg_id = "${module.main-server.main-instance_ssh_sg_id}"
  main-instance_local_ipv4 = "${module.main-server.main-instance_local_ipv4}"
  iam_cloudwatch_s3_profile_id = "${module.main-server.cloudwatch_s3_profile_id}"
  iam_cloudwatch_s3_profile_name = "${module.main-server.cloudwatch_s3_profile_name}"
}

module "jenkins-server" {
  source = "../jenkins-server"
  main-instance_ssh_sg_id = "${module.main-server.main-instance_ssh_sg_id}"
  main-instance_local_ipv4 = "${module.main-server.main-instance_local_ipv4}"
  iam_cloudwatch_s3_profile_id = "${module.main-server.cloudwatch_s3_profile_id}"
  iam_cloudwatch_s3_profile_name = "${module.main-server.cloudwatch_s3_profile_name}"
  depends_on = [module.main-server]
}




