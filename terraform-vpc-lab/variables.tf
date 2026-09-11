variable "aws_region" {
  description = "AWS 리전 정보(서울 리전)"
  type        = string
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR 목록 (가용 영역 a, c 순)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private Subnet CIDR 목록 (가용 영역 a, c 순)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "project_name" {
  description = "프로젝트 이름 (Prefix)"
  type        = string
  default     = "my-eks-2"
}

variable "my_ip" {
  description = "SSH 접속을 위한 관리자 공인 IP"
  type        = string
  default     = "0.0.0.0/0"
}