# ALB 모듈 호출 (Jenkins, FE, BE)
module "alb" {
  source  = "./modules/alb"
  for_each = {
    jenkins = {
      name              = var.alb_jenkins_name
      internal          = false
      security_group_ids = [module.fe_alb_security_group.security_group_id]
      subnet_ids        = module.vpc.public_subnet_ids
    }
    Frontend = {
      name              = var.alb_fe_name
      internal          = false
      security_group_ids = [module.fe_alb_security_group.security_group_id]
      subnet_ids        = module.vpc.public_subnet_ids
    }
    main = {
      name              = var.alb_main_name
      internal          = true
      security_group_ids = [module.be_alb_security_group.security_group_id]
      subnet_ids        = module.vpc.private_subnet_ids
    }
  }

  name              = each.value.name
  internal          = each.value.internal
  security_group_ids = each.value.security_group_ids
  subnet_ids        = each.value.subnet_ids
  tags              = var.alb_tags
}


# module "alb_jenkins" {
#   source            = "./modules/alb"
#   name              = var.alb_jenkins_name
#   internal          = false
#   security_group_ids = [module.fe_alb_security_group.security_group_id]
#   subnet_ids        = module.vpc.public_subnet_ids
#   tags = var.alb_tags
# }

# module "alb_fe" {
#   source            = "./modules/alb"
#   name              = var.alb_fe_name
#   internal          = false
#   security_group_ids = [module.fe_alb_security_group.security_group_id]
#   subnet_ids        = module.vpc.public_subnet_ids
#   tags = var.alb_tags
# }

# module "alb_main" {
#   source            = "./modules/alb"
#   name              = var.alb_main_name
#   internal          = true
#   security_group_ids = [module.be_alb_security_group.security_group_id]
#   subnet_ids        = module.vpc.private_subnet_ids
#   tags = var.alb_tags
# }


module "target_group" {
  source = "./modules/target_group"

  for_each = {
    jenkins = {
      name             = var.tg_jenkins_name
      port             = 8080
      health_check_path = "/health"
    }
    Frontend = {
      name             = var.tg_fe_name
      port             = 3000
      health_check_path = "/"
    }
    Backend = {
      name             = var.tg_be_name
      port             = 8080
      health_check_path = "/api/v1/health"
    }
    ai1 = {
      name             = var.tg_ai1_name
      port             = 5000
      health_check_path = "/ai/health"
    }
    ai2 = {
      name             = var.tg_ai2_name
      port             = 5001
      health_check_path = "/ai/health"
    }
  }

  name             = each.value.name
  port             = each.value.port
  vpc_id           = module.vpc.vpc_id
  health_check_path = each.value.health_check_path
  tags             = var.target_group_tags
}


# 타겟 그룹 모듈 호출
# module "tg_jenkins" {
#   source           = "./modules/target_group"
#   name             = var.tg_jenkins_name
#   port             = 8080
#   vpc_id           = module.vpc.vpc_id
#   health_check_path = "/health"
#   tags = var.target_group_tags
# }

# module "tg_fe" {
#   source           = "./modules/target_group"
#   name             = var.tg_fe_name
#   port             = 3000
#   vpc_id           = module.vpc.vpc_id
#   health_check_path = "/"
#   tags = var.target_group_tags
# }

# module "tg_be" {
#   source           = "./modules/target_group"
#   name             = var.tg_be_name
#   port             = 8080
#   vpc_id           = module.vpc.vpc_id
#   health_check_path = "/api/v1/health"
#   tags = var.target_group_tags
# }

# module "tg_ai1" {
#   source           = "./modules/target_group"
#   name             = var.tg_ai1_name
#   port             = 5000
#   vpc_id           = module.vpc.vpc_id
#   health_check_path = "/ai/health"
#   tags = var.target_group_tags
# }

# module "tg_ai2" {
#   source           = "./modules/target_group"
#   name             = var.tg_ai2_name
#   port             = 5001
#   vpc_id           = module.vpc.vpc_id
#   health_check_path = "/ai/health"
#   tags = var.target_group_tags
# }

module "listener" {
  source = "./modules/listener"

  for_each = {
    jenkins_http = {
      load_balancer_arn = module.alb["jenkins"].alb_arn
      port              = 80
      protocol          = "HTTP"
      target_group_arn  = module.target_group["jenkins"].target_group_arn
      certificate_arn   = null
      redirect          = false
    }
    fe_http_redirect = {
      load_balancer_arn = module.alb["Frontend"].alb_arn
      port              = 80
      protocol          = "HTTP"
      target_group_arn  = null
      certificate_arn   = null
      redirect          = true
    }
    fe_https = {
      load_balancer_arn = module.alb["Frontend"].alb_arn
      port              = 443
      protocol          = "HTTPS"
      target_group_arn  = module.target_group["Frontend"].target_group_arn
      certificate_arn   = var.certificate_arn
      redirect          = false
    }
    be_http_redirect = {
      load_balancer_arn = module.alb["main"].alb_arn
      port              = 80
      protocol          = "HTTP"
      target_group_arn  = null
      certificate_arn   = null
      redirect          = true
    }
    be_https = {
      load_balancer_arn = module.alb["main"].alb_arn
      port              = 443
      protocol          = "HTTPS"
      target_group_arn  = module.target_group["Backend"].target_group_arn
      certificate_arn   = var.certificate_arn
      redirect          = false
    }
  }

  load_balancer_arn = each.value.load_balancer_arn
  port              = each.value.port
  protocol          = each.value.protocol
  target_group_arn  = each.value.target_group_arn
  certificate_arn   = each.value.certificate_arn
  redirect          = each.value.redirect
}


# 리스너 모듈 호출
# module "listener_jenkins" {
#   source            = "./modules/listener"
#   load_balancer_arn = module.alb["jenkins"].alb_arn
#   port              = 80
#   protocol          = "HTTP"
#   target_group_arn  = module.target_group["jenkins"].target_group_arn
# }

# # HTTP 리스너 설정 (80에서 443으로 리디렉션)
# module "listener_fe_http_redirect" {
#   source            = "./modules/listener"
#   load_balancer_arn = module.alb["Frontend"].alb_arn
#   port              = 80
#   protocol          = "HTTP"
#   redirect          = true
# }

# # HTTPS 리스너 설정 (443에서 실제 트래픽 포워딩)
# module "listener_fe_https" {
#   source            = "./modules/listener"
#   load_balancer_arn = module.alb["Frontend"].alb_arn
#   port              = 443
#   protocol          = "HTTPS"
#   target_group_arn  = module.target_group["Frontend"].target_group_arn
#   certificate_arn   = var.certificate_arn
#   redirect          = false
# }

# module "listener_be_http_redirect" {
#   source            = "./modules/listener"
#   load_balancer_arn = module.alb["main"].alb_arn
#   port              = 80
#   protocol          = "HTTP"
#   redirect          = true
# }

# module "listener_be_https" {
#   source            = "./modules/listener"
#   load_balancer_arn = module.alb["main"].alb_arn
#   port              = 443
#   protocol          = "HTTPS"
#   target_group_arn  = module.target_group["Backend"].target_group_arn
#   certificate_arn   = var.certificate_arn
#   redirect          = false
# }


module "listener_rule" {
  source = "./modules/listener_rule"

  for_each = {
    be = {
      listener_arn     = module.listener["be_https"].listener_arn
      priority         = 100
      path_patterns    = var.be_path_patterns
      target_group_arn = module.target_group["Backend"].target_group_arn
    }
    ai = {
      listener_arn     = module.listener["be_https"].listener_arn
      priority         = 200
      path_patterns    = var.ai1_path_patterns
      target_group_arn = module.target_group["ai1"].target_group_arn
    }
    ai2 = {
      listener_arn     = module.listener["be_https"].listener_arn
      priority         = 300
      path_patterns    = var.ai2_path_patterns
      target_group_arn = module.target_group["ai2"].target_group_arn
    }
  }

  listener_arn     = each.value.listener_arn
  priority         = each.value.priority
  path_patterns    = each.value.path_patterns
  target_group_arn = each.value.target_group_arn
}


# 리스너 규칙 모듈 호출
# module "listener_rule_be" {
#   source           = "./modules/listener_rule"
#   listener_arn     = module.listener_be_https.listener_arn
#   priority         = 100
#   path_patterns    = var.be_path_patterns
#   target_group_arn = module.tg_be.target_group_arn
# }

# module "listener_rule_ai" {
#   source           = "./modules/listener_rule"
#   listener_arn     = module.listener_be_https.listener_arn
#   priority         = 200
#   path_patterns    = var.ai1_path_patterns
#   target_group_arn = module.tg_ai1.target_group_arn
# }

# module "listener_rule_ai2" {
#   source           = "./modules/listener_rule"
#   listener_arn     = module.listener_be_https.listener_arn
#   priority         = 300
#   path_patterns    = var.ai2_path_patterns
#   target_group_arn = module.tg_ai2.target_group_arn
# }
