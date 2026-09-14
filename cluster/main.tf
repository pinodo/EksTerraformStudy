# ~/EksTerraformStudy/cluster/main.tf

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "sesac-b2-my-eks-cluster"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  eks_managed_node_groups = {
    backend_nodes = {
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      disired_size = 2
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}