# ALB 모듈 호출 (Jenkins, FE, BE)
module "alb_jenkins" {
  source            = "./modules/alb"
  name              = "jenkins-alb"
  internal          = false
  security_group_ids = [module.alb_security_group.security_group_id]
  subnet_ids        = module.vpc.public_subnet_ids
}

# resource "aws_lb_target_group_attachment" "example" {
#   target_group_arn = module.alb_jenkins.target_group_arn   # ALB 타겟 그룹의 ARN을 변수로 받음
#   target_id        = module.jenkins_instance.instance_id
# }

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
  health_check_path = "/jenkins"
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
  name             = "ai2-target-group"
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

module "listener_fe" {
  source            = "./modules/listener"
  load_balancer_arn = module.alb_fe.alb_arn
  port              = 80
  protocol          = "HTTP"
  target_group_arn  = module.tg_fe.target_group_arn
}

module "listener_be" {
  source            = "./modules/listener"
  load_balancer_arn = module.alb_main.alb_arn
  port              = 80
  protocol          = "HTTP"
  target_group_arn  = module.tg_be.target_group_arn
}

# 리스너 규칙 모듈 호출
module "listener_rule_be" {
  source           = "./modules/listener_rule"
  listener_arn     = module.listener_be.listener_arn
  priority         = 100
  path_patterns    = ["/api/*", "/oauth2/*", "/login/*"]
  target_group_arn = module.tg_be.target_group_arn
}

module "listener_rule_ai" {
  source           = "./modules/listener_rule"
  listener_arn     = module.listener_be.listener_arn
  priority         = 200
  path_patterns    = ["/ai/recommend"]
  target_group_arn = module.tg_ai1.target_group_arn
}

module "listener_rule_ai2" {
  source           = "./modules/listener_rule"
  listener_arn     = module.listener_be.listener_arn
  priority         = 300
  path_patterns    = ["/ai/genproject"]
  target_group_arn = module.tg_ai2.target_group_arn
}
