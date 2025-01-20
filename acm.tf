module "acm" {
  source  = "./modules/acm"

  # 기존 ACM 인증서를 참조
  existing_certificate_arn = data.aws_acm_certificate.existing.arn

  # 기존 Route 53 Hosted Zone ID를 직접 전달
  zone_id = var.existing_zone_id  # var.existing_zone_id는 기존 호스팅 영역의 ID

  domain_name               = var.domain_name
  subject_alternative_names = ["*.cpplab.store"]
  validation_method         = "DNS"

  tags = {
    Environment = var.environment
    Project     = "ECSProject"
  }
}

data "aws_acm_certificate" "existing" {
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}
