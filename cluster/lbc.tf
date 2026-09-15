# ~/EksTerraformStudy/cluster/lbc.tf

resource "aws_iam_policy" "lbc_policy" {
  name        = "sesac-b2-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "LBC가 AWS 네트워크 리소스를 관리하기 위한 정책"
  
  policy = file("${path.module}/iam_policy.json") 
}

module "lbc_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "sesac-b2-aws-load-balancer-controller-role"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:sesac-b2-aws-load-balancer-controller"]
    }
  }

  role_policy_arns = {
    lbc = aws_iam_policy.lbc_policy.arn
  }
}

resource "helm_release" "alb_controller" {
  name       = "sesac-b2-aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  
  values = [
    jsonencode({
      clusterName = module.eks.cluster_name
      region      = "ap-northeast-2"
      vpcId       = data.terraform_remote_state.vpc.outputs.vpc_id
      serviceAccount = {
        create = true
        name   = "sesac-b2-aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.lbc_irsa_role.iam_role_arn
        }
      }
    })
  ]
}