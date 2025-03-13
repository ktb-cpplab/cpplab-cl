# resource "aws_route53_zone" "main" {
#   name = var.domain_name
# }

# # SOA Record
# resource "aws_route53_record" "soa" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = var.domain_name
#   type    = "SOA"
#   ttl     = 900
#   records = [
#     "ns-2005.awsdns-58.co.uk. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
#   ]
# }

# # NS Record
# resource "aws_route53_record" "ns" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = var.domain_name
#   type    = "NS"
#   ttl     = 172800
#   records = [
#     "ns-2005.awsdns-58.co.uk.",
#     "ns-101.awsdns-12.com.",
#     "ns-699.awsdns-23.net.",
#     "ns-1250.awsdns-28.org."
#   ]
# }

# # Dynamic A Records (Frontend ALB)
# resource "aws_route53_record" "fe" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "fe.${var.domain_name}"
#   type    = "A"
#   ttl     = 300
#   records = [var.alb["Frontend"].alb_dns_name]
# }

# # Dynamic A Records (Backend ALB)
# resource "aws_route53_record" "be" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "be.${var.domain_name}"
#   type    = "A"
#   ttl     = 300
#   records = [var.alb["main"].alb_dns_name]
# }

# # Dynamic A Records (Root Domain - Frontend)
# resource "aws_route53_record" "root_a" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = var.domain_name
#   type    = "A"
#   ttl     = 300
#   records = [var.alb["Frontend"].alb_dns_name]
# }

# # Dynamic A Records (www - Frontend)
# resource "aws_route53_record" "www" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = "www.${var.domain_name}"
#   type    = "A"
#   ttl     = 300
#   records = [var.alb["Frontend"].alb_dns_name]
# }

# # CNAME Record for ACM Validation
# resource "aws_route53_record" "cname" {
#   zone_id = aws_route53_zone.main.zone_id
#   name    = var.domain_validation_options[0].resource_record_name
#   type    = var.domain_validation_options[0].resource_record_type
#   ttl     = 300
#   records = [var.domain_validation_options[0].resource_record_value]
# }
