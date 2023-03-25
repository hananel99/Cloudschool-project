
data "terraform_remote_state" "site" {
  backend = "s3"
  config = {
    bucket = var.terraform_bucket
    key = var.site_module_state_path
    region = var.region
  }
}

resource "aws_launch_configuration" "workshop-app_lc" {
  user_data =   templatefile("${path.module}/templates/project-app.sh",{main-instance_local_ipv4 = var.main-instance_local_ipv4})
   lifecycle {  # This is necessary to make terraform launch configurations work with autoscaling groups
    create_before_destroy = true
  }
  security_groups = [aws_security_group.workshop-app.id, var.main-instance_vault_sg_id, var.main-instance_consul_sg_id, var.main-instance_ssh_sg_id]
  name_prefix = "${var.cluster_name}_lc"
  enable_monitoring = false

  image_id = var.ami
  instance_type = var.instance_type
  key_name = data.terraform_remote_state.site.outputs.admin_key_name
  iam_instance_profile = var.iam_cloudwatch_s3_profile_name
  //??? complete the missing attribute    
}

resource "aws_autoscaling_group" "workshop-app_asg" {
  name = "${var.cluster_name}_asg"
  launch_configuration = "${aws_launch_configuration.workshop-app_lc.name}"
  max_size = var.workshop-app_cluster_size_max
  min_size = var.workshop-app_cluster_size_min
  desired_capacity = var.workshop-app_cluster_size_min
  vpc_zone_identifier = element(data.terraform_remote_state.site.outputs.public_subnets, 0)

  load_balancers = [ aws_elb.workshop-app.name ]

  tag {
    key = "Name"
    value = var.cluster_name
    propagate_at_launch = true
  }

  tag {
    key = "Team"
    value = "Workshop"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "workshop-app_lb" {
  //??? complete the missing attributes

  name = "${var.cluster_name}-lb"
  description = "${var.cluster_name}-lb"
  vpc_id = data.terraform_remote_state.site.outputs.vpc_id

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
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

resource "aws_security_group" "workshop-app" {
    //??? complete the missing attributes

  lifecycle {  
    create_before_destroy = true
  }

  name = "${var.cluster_name}_workshop_app"
  description = "sg for ${var.cluster_name} workshop app"
  vpc_id = data.terraform_remote_state.site.outputs.vpc_id

  ingress {
    description      = "http"
    from_port        = 8080
    to_port          = 8080
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

resource "aws_elb" "workshop-app" {
  name = "${var.cluster_name}-lb"
  listener {
    instance_port = 8080
    instance_protocol = "HTTP"
    lb_port = 80
    lb_protocol = "HTTP"
  }

  subnets = element(data.terraform_remote_state.site.outputs.public_subnets, 0)
  security_groups = [aws_security_group.workshop-app_lb.id, aws_security_group.workshop-app.id]
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/checkhealth"
    interval            = 30
  }  
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  //??? complete the missing attributes

}