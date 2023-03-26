output "main-instance_vault_sg_id"{
    value = aws_security_group.main-instance_vault.id
}

output "main-instance_consul_sg_id"{
    value = aws_security_group.main-instance_consul.id
}

output "main-instance_local_ipv4"{
    value = aws_instance.main-server_lc[0].private_ip
}

output "main-instance_ssh_sg_id"{
    value = aws_security_group.main-instance-ssh.id
}

output "cloudwatch_s3_profile_id"{
        value = aws_iam_instance_profile.cloudwatch_s3_profile.id
}

output "cloudwatch_s3_profile_name"{
        value = aws_iam_instance_profile.cloudwatch_s3_profile.name
}