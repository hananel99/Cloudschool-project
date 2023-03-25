data "terraform_remote_state" "site" {
  backend = "s3"
  config = {
    bucket = var.terraform_bucket
    key = var.site_module_state_path
    region = var.region
  }
}

resource "aws_security_group" "rds-mysql-db" {

  name = "workshop_rds_sg"
  description = "sg for workshop rds"
  vpc_id = data.terraform_remote_state.site.outputs.vpc_id


  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "TCP"
    cidr_blocks = [data.terraform_remote_state.site.outputs.vpc_cidr]
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [data.terraform_remote_state.site.outputs.vpc_cidr]
  }
}

resource "aws_db_subnet_group" "rds-db-default-group" {
  name       = "rds-db-default-group"
  subnet_ids = concat(element(data.terraform_remote_state.site.outputs.private_subnets, 0), element(data.terraform_remote_state.site.outputs.public_subnets, 0))
  tags = {
    Name = "My DB subnet group"
    Source = "Terraform"
  }

}

resource "aws_db_instance" "rds-db" {
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  name                 = var.name
  username             = var.database_user
  password             = var.database_password
  parameter_group_name = "default.mysql8.0"
  multi_az = var.multi_az
  apply_immediately = var.apply_immediately
  identifier = var.identifier  
  publicly_accessible = var.publicly_accessible  
  storage_type = var.storage_type  
  availability_zone = var.availability_zone
  skip_final_snapshot = var.skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.rds-mysql-db.id]  
  db_subnet_group_name = aws_db_subnet_group.rds-db-default-group.name

}