# ~/EksTerraformStudy/ecr/main.tf

locals {
  repository_names = ["b2-msa-gateway-1", "b2-msa-auth-1", "b2-msa-order-1", "b2-nginx-test-1"]
}

resource "aws_ecr_repository" "msa_repos" {
  for_each = toset(local.repository_names)

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "dev"
    Project     = "eks-project"
  }
}

resource "aws_ecr_lifecycle_policy" "cleanup_policy" {
  for_each   = aws_ecr_repository.msa_repos
  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}