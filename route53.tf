module "route53_zones" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "~> 4.0"

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
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 4.0"

  zone_name = "cpplab.store"

  records = [
    # 프론트엔드 ALB 연결
    {
      name  = "fe.cpplab.store"
      type  = "A"
      alias = {
        name    = module.alb["Frontend"].alb_dns_name
        zone_id = module.alb["Frontend"].alb_zone_id
      }
    },
    # www.cpplab.store 연결
    {
      name  = "www.cpplab.store"
      type  = "A"
      alias = {
        name    = module.alb["Frontend"].alb_dns_name
        zone_id = module.alb["Frontend"].alb_zone_id
      }
    },
    # 백엔드 ALB 연결
    {
      name  = "be.cpplab.store"
      type  = "A"
      alias = {
        name    = module.alb["main"].alb_dns_name
        zone_id = module.alb["main"].alb_zone_id
      }
    }
  ]

  depends_on = [module.route53_zones]
}
