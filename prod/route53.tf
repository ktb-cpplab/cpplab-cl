# Route 53 레코드 업데이트
module "route53_records" {
  source  = "../modules/route53/records"

  # 기존 Hosted Zone ID 전달
  zone_id = var.existing_zone_id
  zone_name = "cpplab.store"  # 기존 호스팅 영역 이름 전달

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
    # 루트 도메인 연결
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
}
