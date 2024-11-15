# ALB 모듈 호출 (Jenkins, FE, BE)
module "alb_jenkins" {
  source            = "./modules/alb"
  name              = "jenkins-alb"
  internal          = false
  security_group_ids = [module.alb_security_group.security_group_id]
  subnet_ids        = module.vpc.public_subnet_ids
}

module "alb_fe" {
  source            = "./modules/alb"
  name              = "alb-fe"
  internal          = false
  security_group_ids = [module.alb_security_group.security_group_id]
  subnet_ids        = module.vpc.public_subnet_ids
}

module "alb_main" {
  source            = "./modules/alb"
  name              = "alb-main"
  internal          = false
  security_group_ids = [module.alb_security_group.security_group_id]
  subnet_ids        = module.vpc.public_subnet_ids
}

# 타겟 그룹 모듈 호출
module "tg_jenkins" {
  source           = "./modules/target_group"
  name             = "jenkins-target-group"
  port             = 8080
  vpc_id           = module.vpc.vpc_id
  health_check_path = "/health"
}

module "tg_fe" {
  source           = "./modules/target_group"
  name             = "frontend-target-group"
  port             = 3000
  vpc_id           = module.vpc.vpc_id
  health_check_path = "/"
}

module "tg_be" {
  source           = "./modules/target_group"
  name             = "backend-target-group"
  port             = 8080
  vpc_id           = module.vpc.vpc_id
  health_check_path = "/api/v1/health"
}

module "tg_ai1" {
  source           = "./modules/target_group"
  name             = "pickle-tg"
  port             = 5000
  vpc_id           = module.vpc.vpc_id
  health_check_path = "/ai/health"
}

module "tg_ai2" {
  source           = "./modules/target_group"
  name             = "progen-tg"
  port             = 5001
  vpc_id           = module.vpc.vpc_id
  health_check_path = "/ai/health"
}

# 리스너 모듈 호출
module "listener_jenkins" {
  source            = "./modules/listener"
  load_balancer_arn = module.alb_jenkins.alb_arn
  port              = 80
  protocol          = "HTTP"
  target_group_arn  = module.tg_jenkins.target_group_arn
}

# HTTP 리스너 설정 (80에서 443으로 리디렉션)
module "listener_fe_http_redirect" {
  source            = "./modules/listener"
  load_balancer_arn = module.alb_fe.alb_arn
  port              = 80
  protocol          = "HTTP"
  redirect          = true
}

# HTTPS 리스너 설정 (443에서 실제 트래픽 포워딩)
module "listener_fe_https" {
  source            = "./modules/listener"
  load_balancer_arn = module.alb_fe.alb_arn
  port              = 443
  protocol          = "HTTPS"
  target_group_arn  = module.tg_fe.target_group_arn
  certificate_arn   = var.certificate_arn
  redirect          = false
}

module "listener_be_http_redirect" {
  source            = "./modules/listener"
  load_balancer_arn = module.alb_main.alb_arn
  port              = 80
  protocol          = "HTTP"
  redirect          = true
}

module "listener_be_https" {
  source            = "./modules/listener"
  load_balancer_arn = module.alb_main.alb_arn
  port              = 443
  protocol          = "HTTPS"
  target_group_arn  = module.tg_be.target_group_arn
  certificate_arn   = var.certificate_arn
  redirect          = false
}

# 리스너 규칙 모듈 호출
module "listener_rule_be" {
  source           = "./modules/listener_rule"
  listener_arn     = module.listener_be_https.listener_arn
  priority         = 100
  path_patterns    = ["/api/*", "/oauth2/*", "/login/*"]
  target_group_arn = module.tg_be.target_group_arn
}

module "listener_rule_ai" {
  source           = "./modules/listener_rule"
  listener_arn     = module.listener_be_https.listener_arn
  priority         = 200
  path_patterns    = ["/ai/recommend"]
  target_group_arn = module.tg_ai1.target_group_arn
}

module "listener_rule_ai2" {
  source           = "./modules/listener_rule"
  listener_arn     = module.listener_be_https.listener_arn
  priority         = 300
  path_patterns    = ["/ai/genproject"]
  target_group_arn = module.tg_ai2.target_group_arn
}
