output "bastion_public_ip" {
  description = "Bastion Host 공인 IP"
  value       = aws_instance.bastion.public_ip
}

output "private_ec2_ip" {
  description = "Private EC2 사설 IP"
  value       = aws_instance.private_ec2.private_ip
}

output "command_for_jump_host" {
  description = "Bastion Host를 거쳐서 Private EC2로 SSH 접속하는 명령어"
  value       = "ssh -i ${var.project_name}-key.pem -o ProxyCommand=\"ssh -i ${var.project_name}-key.pem -W %h:%p ubuntu@${aws_instance.bastion.public_ip}\" ubuntu@${aws_instance.private_ec2.private_ip}"
}

output "command_for_bastion_host" {
  description = "Bastion Host로 SSH 접속하는 명령어"
  value       = "ssh -i ${var.project_name}-key.pem ubuntu@${aws_instance.bastion.public_ip}"
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}