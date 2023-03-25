data "terraform_remote_state" "site" {
  backend = "s3"
  config = {
    bucket = var.terraform_bucket
    key = var.site_module_state_path
    region = var.region
  }
}

resource "aws_instance" "jenkins-server" {
  user_data =   templatefile("${path.module}/templates/jenkins-install.sh", {"main-instance_local_ipv4"= var.main-instance_local_ipv4 })
  security_groups = [var.main-instance_ssh_sg_id, aws_security_group.jenkins-server.id ]
  subnet_id = element(element(data.terraform_remote_state.site.outputs.public_subnets, 0), 0)
  count = 1
  ami = var.ami
  instance_type = var.instance_type
  key_name = data.terraform_remote_state.site.outputs.admin_key_name
  iam_instance_profile = var.iam_cloudwatch_s3_profile_name
  tags  ={
    Name = "Jenkins-server"
    Source = "Terraform"
  }
}

resource "aws_security_group" "jenkins-server" {
  lifecycle {  
    create_before_destroy = true
  }

  name = "${var.cluster_name}_services_jenkins"
  description = "sg for ${var.cluster_name} jenkins service"
  vpc_id = data.terraform_remote_state.site.outputs.vpc_id
  ingress {
    description      = "jenkins in docker"
    from_port        = 8083
    to_port          = 8083
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description      = "jenkins in docker"
    from_port        = 50003
    to_port          = 50003
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}