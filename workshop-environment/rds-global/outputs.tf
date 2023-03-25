output "database_user"{
  value = var.database_user
}

output "database_password"{
  value = var.database_password
}
output "database_url"{
  value = aws_db_instance.rds-db.endpoint
}

output "rds-mysql-db_sg_id"{
  value = aws_security_group.rds-mysql-db.id
}