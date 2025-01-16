module "acm" {
  source  = "./modules/acm"
  version = "~> 4.0"

  domain_name               = var.domain_name 
  zone_id                   = module.route53_zones.route53_zone_zone_id["cpplab.store"]
  validation_method         = "DNS" 
  subject_alternative_names = [
    "*.cpplab.store"
  ]

  wait_for_validation = true

  tags = {
    Environment = "dev"
    Project     = "ECSProject"
  }
}