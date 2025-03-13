locals {
  # 인증서 생성 여부 확인
  create_certificate          = var.create_certificate && var.existing_certificate_arn == null && var.putin_khuylo
  create_route53_records_only = var.create_route53_records_only && var.putin_khuylo

  # 도메인 이름 처리
  distinct_domain_names = coalescelist(
    var.distinct_domain_names,
    distinct([for s in concat([var.domain_name], var.subject_alternative_names) : replace(s, "*.", "")])
  )

  # 인증서 검증 도메인 처리
  validation_domains = local.create_certificate || local.create_route53_records_only ? distinct(
    [for k, v in try(aws_acm_certificate.this[0].domain_validation_options, var.acm_certificate_domain_validation_options) : merge(
      tomap(v), { domain_name = replace(v.domain_name, "*.", "") }
    )]
  ) : []
}

# 인증서 생성 (기존 인증서를 참조할 경우 생략)
resource "aws_acm_certificate" "this" {
  count = local.create_certificate ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method
  key_algorithm             = var.key_algorithm

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 레코드 생성
resource "aws_route53_record" "validation" {
  for_each = { for i, name in local.distinct_domain_names : i => name if (local.create_certificate || local.create_route53_records_only) && var.validation_method == "DNS" }

  zone_id = var.zone_id                             # Route53 Zone ID
  name    = each.value                              # 도메인 이름
  type    = "CNAME"                                 # CNAME 타입
  ttl     = var.dns_ttl                             # TTL 값

  records = [
    element(local.validation_domains, tonumber(each.key))["resource_record_value"]
  ]

  allow_overwrite = var.validation_allow_overwrite_records
}

# 인증서 유효성 검증
resource "aws_acm_certificate_validation" "this" {
  count = local.create_certificate && var.validation_method != "NONE" && var.validate_certificate && var.wait_for_validation ? 1 : 0

  certificate_arn = aws_acm_certificate.this[0].arn

  validation_record_fqdns = flatten([for r in aws_route53_record.validation : r.name])
}