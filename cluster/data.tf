# ~/EksTerraformStudy/cluster/data.tf

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "sesac-b2-terraform-state-bucket"
    key    = "dev/vpc/terraform.tfstate"
    region = "ap-northeast-2"
  }
}