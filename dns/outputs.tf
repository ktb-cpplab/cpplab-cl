output "acm_certificate_arn" {
  value       = aws_acm_certificate.your_acm_resource.arn
  description = "ARN of the ACM certificate"
}
