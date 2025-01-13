module "route53" {
  source                  = "./modules/route53"
  domain_name             = "cpplab.store"
  domain_validation_options = module.acm.domain_validation_options

  additional_records = [
    {
      name  = "fe.cpplab.store"
      type  = "A"
      value = module.alb_fe.alb_dns_name # 프론트엔드 ALB DNS 이름
    },
    {
      name  = "be.cpplab.store"
      type  = "A"
      value = module.alb_main.alb_dns_name # 백엔드 ALB DNS 이름
    },
    {
      name  = "www.cpplab.store"
      type  = "A"
      value = module.alb_fe.alb_dns_name # www를 프론트엔드 ALB로 연결
    }
  ]
}
