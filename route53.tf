module "route53_zones" {
  source  = "./modules/route53/zones"

  zones = {
    "cpplab.store" = {
      comment = "Hosted zone for cpplab.store"
      tags = {
        Project = "ECSProject"
        Env     = "dev"
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}

module "route53_records" {
  source  = "./modules/route53/records"

  zone_name = "cpplab.store"

  records = [
    # 프론트엔드 ALB 연결
    {
      name  = "fe"
      type  = "A"
      alias = {
        name    = module.alb["Frontend"].alb_dns_name
        zone_id = module.alb["Frontend"].alb_zone_id
      }
    },
    # www.cpplab.store 연결
    {
      name  = "www"
      type  = "A"
      alias = {
        name    = module.alb["Frontend"].alb_dns_name
        zone_id = module.alb["Frontend"].alb_zone_id
      }
    },
    {
      name  = ""
      type  = "A"
      alias = {
        name    = module.alb["Frontend"].alb_dns_name
        zone_id = module.alb["Frontend"].alb_zone_id
      }
    },
    # 백엔드 ALB 연결
    {
      name  = "be"
      type  = "A"
      alias = {
        name    = module.alb["main"].alb_dns_name
        zone_id = module.alb["main"].alb_zone_id
      }
    }
  ]

  depends_on = [module.route53_zones]
}
