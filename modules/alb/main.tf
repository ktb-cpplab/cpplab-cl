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

# BE 타겟 그룹
resource "aws_lb_target_group" "be" {
  name       = "be-target-group"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc_id
  target_type = "instance"
}

# FE 타겟 그룹
resource "aws_lb_target_group" "fe" {
  name       = "fe-target-group"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc_id
  target_type = "instance"
}

# AI 타겟 그룹
resource "aws_lb_target_group" "ai" {
  name       = "ai-target-group"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc_id
  target_type = "instance"
}

# ALB의 HTTP 리스너 설정
resource "aws_lb_listener" "main_listener" {
  load_balancer_arn = aws_lb.main_lb.arn  # 메인 ALB의 ARN 
  port              = 80                    # HTTP 포트
  protocol          = "HTTP"               

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.be.arn  # 기본 BE 대상 그룹 지정
  }
}

# FE 서비스로의 트래픽 라우팅 규칙
resource "aws_lb_listener_rule" "fe_rule" {
  listener_arn = aws_lb_listener.main_listener.arn
  priority     = 200  # 우선순위 조정

  condition {
    host_header {
      values = [var.frontend_host]  # FE 서비스를 위한 호스트 헤더
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fe.arn  # FE 타겟 그룹으로 트래픽 전달
  }
}

# BE 서비스로의 트래픽 라우팅 규칙
resource "aws_lb_listener_rule" "be_rule" {
  listener_arn = aws_lb_listener.main_listener.arn
  priority     = 100  # 우선순위 조정

  condition {
    host_header {
      values = [var.backend_host]  # BE 서비스를 위한 호스트 헤더
    }
  }
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.be.arn  # BE 타겟 그룹으로 트래픽 전달
  }
}

# AI 서비스로의 트래픽 라우팅 규칙
resource "aws_lb_listener_rule" "ai_rule" {
  listener_arn = aws_lb_listener.main_listener.arn
  priority     = 300  # 우선순위 조정

  condition {
    host_header {
      values = [var.ai_host]  # FE 서비스를 위한 호스트 헤더
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ai.arn  # FE 타겟 그룹으로 트래픽 전달
  }
}