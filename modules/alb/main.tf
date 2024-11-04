# Jenkins 로드밸런서
resource "aws_lb" "jenkins_lb" {
  name               = "${var.lb_name}-jenkins"  # Jenkins ALB 이름
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
}

# Jenkins 타겟 그룹
resource "aws_lb_target_group" "jk" {
  name       = "jenkins-target-group"
  port       = 8080
  protocol   = "HTTP"
  vpc_id     = var.vpc_id
  target_type = "instance"
}

# Jenkins ALB의 HTTP 리스너 설정
resource "aws_lb_listener" "jenkins_listener" {
  load_balancer_arn = aws_lb.jenkins_lb.arn  # Jenkins ALB의 ARN
  port              = 80                    # Jenkins ALB에서 트래픽 수신 포트
  protocol          = "HTTP"                  

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jk.arn  # 기본 타겟 그룹 설정
  }
}

# FE, BE, AI 로드밸런서
resource "aws_lb" "main_lb" {
  name               = "${var.lb_name}-main"  # 메인 ALB 이름
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
}

# 프론트엔드 타겟 그룹 (기본 타겟)
resource "aws_lb_target_group" "fe" {
  name                 = "fe-target-group"
  port                 = 3000                       # 프론트엔드 서비스 포트
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = var.deregistration_delay_time

  health_check {
    path                = "/"                # 헬스 체크 경로
    interval            = 30                       # 헬스 체크 간격 (초)
    timeout             = 5                        # 헬스 체크 타임아웃 (초)
    healthy_threshold   = 3                        # 헬스 체크 성공 기준 횟수
    unhealthy_threshold = 3                        # 헬스 체크 실패 기준 횟수
    matcher             = "200"                    # 헬스 체크 상태 코드 매처
  }
}

# 백엔드 타겟 그룹
resource "aws_lb_target_group" "be" {
  name                 = "be-target-group"
  port                 = 8080                       # 백엔드 서비스 포트
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = var.deregistration_delay_time

  health_check {
    path                = "/api/v1/auth/my"             # 헬스 체크 경로
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

# AI 타겟 그룹
resource "aws_lb_target_group" "ai" {
  name                 = "ai-target-group"
  port                 = 5000                       # AI 서비스 포트
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = var.deregistration_delay_time

  health_check {
    path                = "/ai/health"              # 헬스 체크 경로
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

# AI2 타겟 그룹
resource "aws_lb_target_group" "ai2" {
  name                 = "ai2-target-group"
  port                 = 5001                       # AI 서비스 포트
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = var.deregistration_delay_time

  health_check {
    path                = "/ai/health"              # 헬스 체크 경로
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
}

# ALB의 HTTP 리스너 설정
resource "aws_lb_listener" "main_listener" {
  load_balancer_arn = aws_lb.main_lb.arn  # 메인 ALB의 ARN
  port              = 80                  # ALB에서 트래픽 수신 포트
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fe.arn  # 기본 프론트엔드 타겟 그룹
  }
}

# 백엔드(/api) 경로로의 트래픽 라우팅 규칙
resource "aws_lb_listener_rule" "be_rule" {
  listener_arn = aws_lb_listener.main_listener.arn
  priority     = 100  # 우선순위 설정

  condition {
    path_pattern {
      values = ["/api/*","/oauth2/*"]  # /api로 시작하는 모든 경로
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.be.arn  # 백엔드 타겟 그룹으로 트래픽 전달
  }
}

# AI(/ai) 경로로의 트래픽 라우팅 규칙
resource "aws_lb_listener_rule" "ai_rule" {
  listener_arn = aws_lb_listener.main_listener.arn
  priority     = 200  # 우선순위 설정

  condition {
    path_pattern {
      values = ["/ai/*"]  # /ai로 시작하는 모든 경로
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ai.arn  # AI 타겟 그룹으로 트래픽 전달
  }
}

# AI2 (/ai/*) 경로로의 트래픽 라우팅 규칙
resource "aws_lb_listener_rule" "ai2_rule" {
  listener_arn = aws_lb_listener.main_listener.arn
  priority     = 300  # 우선순위 설정 (다른 규칙과 겹치지 않도록 설정)

  condition {
    path_pattern {
      values = ["/ai/*"]  # /ai2로 시작하는 모든 경로
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ai2.arn  # AI2 타겟 그룹으로 트래픽 전달
  }
}