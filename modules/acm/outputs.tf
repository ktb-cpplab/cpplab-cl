# output "acm_certificate_arn" {
#   description = "The ARN of the certificate"
#   value       = try(aws_acm_certificate_validation.this[0].certificate_arn, aws_acm_certificate.this[0].arn, "")
# }

# output "acm_certificate_domain_validation_options" {
#   description = "A list of attributes to feed into other resources to complete certificate validation. Can have more than one element, e.g. if SANs are defined. Only set if DNS-validation was used."
#   value       = flatten(aws_acm_certificate.this[*].domain_validation_options)
# }

# output "acm_certificate_status" {
#   description = "Status of the certificate."
#   value       = try(aws_acm_certificate.this[0].status, "")
# }

# output "acm_certificate_validation_emails" {
#   description = "A list of addresses that received a validation E-Mail. Only set if EMAIL-validation was used."
#   value       = flatten(aws_acm_certificate.this[*].validation_emails)
# }

# output "validation_route53_record_fqdns" {
#   description = "List of FQDNs built using the zone domain and name."
#   value       = aws_route53_record.validation[*].fqdn
# }

# output "distinct_domain_names" {
#   description = "List of distinct domains names used for the validation."
#   value       = local.distinct_domain_names
# }

# output "validation_domains" {
#   description = "List of distinct domain validation options. This is useful if subject alternative names contain wildcards."
#   value       = local.validation_domains
# }

output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate, either existing or newly created."
  value = var.existing_certificate_arn != null ? var.existing_certificate_arn : (
    length(aws_acm_certificate.this) > 0 ? aws_acm_certificate.this[0].arn : ""
  )
}

output "acm_certificate_domain_validation_options" {
  description = "A list of attributes to feed into other resources to complete certificate validation. Can have more than one element, e.g., if SANs are defined. Only set if DNS-validation was used."
  value       = flatten(aws_acm_certificate.this[*].domain_validation_options)
}

output "acm_certificate_status" {
  description = "Status of the certificate."
  value       = try(aws_acm_certificate.this[0].status, "")
}
# 출력 - 인증서 ARN
output "certificate_arn" {
  value = var.existing_certificate_arn != null ? var.existing_certificate_arn : aws_acm_certificate.this[0].arn
}

# 출력 - Route53 레코드 FQDNs
output "validation_route53_record_fqdns" {
  description = "List of FQDNs built using the zone domain and name."
  value       = [for r in aws_route53_record.validation : r.name]
}