# ~/EksTerraformStudy/ecr/outputs.tf

output "repository_urls" {
  description = "생성된 각 리포지토리의 접속 주소"

  # 각 리포지토리 이름과 URL을 매핑하여 출력
  value = {
    for k, v in aws_ecr_repository.msa_repos : k => v.repository_url
  }
}