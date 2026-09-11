# 1. SSH Key 쌍 만들기(공개키 + 개인키) (테라폼이 만듦)
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. 공개키(Public Key)를 AWS EC2에 등록
resource "aws_key_pair" "key_pair" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# 3. 개인키(Private Key) 파일로 내려 받기(.pem)
resource "local_file" "private_key" {
  filename        = "${path.module}/${var.project_name}-key.pem"
  file_permission = "0400"
  content         = tls_private_key.ssh_key.private_key_pem
}