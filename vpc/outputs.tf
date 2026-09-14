# ~/EksTerraformStudy/vpc/outputs.tf

output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private Subnet 리스트 (EKS 노드 배치)"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public Subnet ID 리스트"
  value       = module.vpc.public_subnets
}

output "vpc_cidr" {
  description = "VPC의 CIDR 대역"
  value       = module.vpc.default_vpc_cidr_block
}