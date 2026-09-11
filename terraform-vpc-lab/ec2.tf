# Ubuntu 24.04 LTS AMI 정보 조회 (제조사 Canonical 공식 ID: 099720109477)
data "aws_ami" "ubuntu_24_04" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# Bastion Host (첫 번째 Public Subnet에 배치)
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu_24_04.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.key_pair.key_name
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "${var.project_name}-bastion-ebs"
    }
  }

  tags = {
    Name = "${var.project_name}-bastion-host"
  }
}

# Pirvate EC2 (첫 번째 Private Subnet에 배치)
resource "aws_instance" "private_ec2" {
  ami                    = data.aws_ami.ubuntu_24_04.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.key_pair.key_name
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.private_ec2.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "${var.project_name}-private-ec2-ebs"
    }
  }

  tags = {
    Name = "${var.project_name}-private-ec2"
  }
}