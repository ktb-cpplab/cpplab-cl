resource "aws_lb" "this" {
  name               = var.lb_name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "be" {
  name       = "be-target-group"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_target_group" "fe" {
  name       = "fe-target-group"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc_id
  target_type = "instance"
}

# ALB의 HTTP 리스너 설정
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn  # ALB의 ARN을 지정하여 리스너를 연결
  port              = 80               # HTTP 포트를 통해 트래픽 수신
  protocol          = "HTTP"           # HTTP 프로토콜 사용

  # 기본 동작으로 BE 대상 그룹으로 트래픽 전달
  default_action {
    type             = "forward"       # 트래픽의 방향 설정
    target_group_arn = aws_lb_target_group.be.arn  # 기본 대상 그룹 지정 
  }
}

# FE 서비스로의 트래픽 라우팅 규칙
resource "aws_lb_listener_rule" "fe_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  condition {
    host_header {
      values = [var.frontend_host]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fe.arn
  }
}

# BE 서비스로의 트래픽 라우팅 규칙
resource "aws_lb_listener_rule" "be_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    host_header {
      values = [var.backend_host]
    }
  }
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.be.arn
  }
}