resource "aws_route53_zone" "main" {
  name = var.domain_name
}

resource "aws_route53_record" "cert_validation" {
  for_each = { for dvo in var.domain_validation_options : dvo.domain_name => dvo }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  ttl     = 300
  records = [each.value.resource_record_value]
}

resource "aws_route53_record" "additional_records" {
  for_each = { for record in var.additional_records : record.name => record }

  zone_id = aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.value]
}
