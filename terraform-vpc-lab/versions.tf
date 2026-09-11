terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # 5.0~5.9 (마이너 버전만 바꿀 수 있음)
    }
  }
}

provider "aws" {
  region = var.aws_region
}