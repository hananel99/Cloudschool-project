
data "terraform_remote_state" "site" {
  backend = "s3"
  config = {
    bucket = var.terraform_bucket
    key = var.site_module_state_path
    region = var.region
  }
}

resource "aws_instance" "main-server_lc" {
  user_data = templatefile("${path.module}/templates/main-instance.sh",{database_url_terraform = var.database_url, database_username_terraform = var.database_user, database_password_terraform = var.database_password })
  security_groups = [aws_security_group.main-instance_vault.id, aws_security_group.main-instance_consul.id, aws_security_group.main-instance-ssh.id, aws_security_group.main-instance_grafana.id ]
  subnet_id = element(element(data.terraform_remote_state.site.outputs.public_subnets, 0), 0)
  count = 1
  ami = var.ami
  instance_type = var.instance_type
  key_name = data.terraform_remote_state.site.outputs.admin_key_name
  iam_instance_profile = aws_iam_instance_profile.cloudwatch_s3_profile.name
  tags  ={
    Name = "Main-server"
    Source = "Terraform"
  }
}

resource "aws_security_group" "main-instance_vault" {
  lifecycle {  
    create_before_destroy = true
  }

  name = "${var.cluster_name}_services_vault"
  description = "sg for ${var.cluster_name} vault service"
  vpc_id = data.terraform_remote_state.site.outputs.vpc_id
  ingress {
    description      = "vault"
    from_port        = 8200
    to_port          = 8200
    protocol         = "tcp"
    self = true
  }
  ingress {
    description      = "vault-debug"
    from_port        = 8200
    to_port          = 8200
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
resource "aws_security_group" "main-instance_consul" {
  lifecycle {  
    create_before_destroy = true
  }

  name = "${var.cluster_name}_services_consul"
  description = "sg for ${var.cluster_name} consul service"
  vpc_id = data.terraform_remote_state.site.outputs.vpc_id
  ingress {
    description      = "consul"
    from_port        = 8500
    to_port          = 8500
    protocol         = "tcp"
    self = true
  }
  ingress {
    description      = "consul-debug"
    from_port        = 8500
    to_port          = 8500
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description      = "consul"
    from_port        = 8600
    to_port          = 8600
    protocol         = "tcp"
    self = true
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "main-instance-ssh" {
    lifecycle {  
    create_before_destroy = true
  }

  name = "${var.cluster_name}_ssh"
  description = "sg for ${var.cluster_name} ssh service"
  vpc_id = data.terraform_remote_state.site.outputs.vpc_id
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
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

resource "aws_security_group" "main-instance_grafana" {
  lifecycle {  
    create_before_destroy = true
  }

  name = "${var.cluster_name}_services_grafana"
  description = "sg for ${var.cluster_name} grafana service"
  vpc_id = data.terraform_remote_state.site.outputs.vpc_id
  ingress {
    description      = "grafana"
    from_port        = 3000
    to_port          = 3000
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


resource "aws_iam_role" "assume_role" {
  name = "assume_role"

  assume_role_policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
)

  tags = {
      Name = "assume_role"
  }
}

resource "aws_iam_instance_profile" "cloudwatch_s3_profile" {
  name = "cloudwatch_s3_profile"
  role = aws_iam_role.assume_role.name
}

resource "aws_iam_role_policy" "cloudwatch_s3_policy" {
  name = "cloudwatch_s3_policy"
  role = aws_iam_role.assume_role.id

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
          "s3:*",
          "cloudwatch:*",
          "logs:*"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    }

  )
}