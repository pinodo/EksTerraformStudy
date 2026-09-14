# ~/EksTerraformStudy/cluster/irsa.tf

module "s3_read_irsa_role" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"
  
  role_name = "s3-read-only-role"
  
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:s3-read-sa"]
    }
  }
  
  role_policy_arns = {
    s3_read = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

  tags = {
    Environment = "dev"
  }
}

resource "kubernetes_service_account_v1" "s3_read_sa" {
  metadata {
    name        = "s3-read-sa"
    namespace   = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.s3_read_irsa_role.iam_role_arn
    }
  }
}