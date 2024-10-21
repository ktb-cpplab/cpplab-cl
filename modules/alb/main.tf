# fe, be, ai 로드밸런서
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

resource "aws_lb_target_group" "ai" {
  name       = "ai-target-group"
  port       = 80  # AI 서비스에서 사용하는 포트. 필요에 따라 조정해야 합니다.
  protocol   = "HTTP"  # AI 서비스에서 사용하는 프로토콜
  vpc_id     = var.vpc_id
  target_type = "instance"  # 기본 설정으로, AI 서비스가 EC2 인스턴스로 호스팅될 경우
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

# AI 서비스로의 트래픽 라우팅 규칙
resource "aws_lb_listener_rule" "ai_rule" {
  listener_arn = aws_lb_listener.http.arn  # 기존 ALB 리스너과 같은 ARN
  priority     = 300  # 다른 규칙과의 우선 순위를 조정하기 위해 설정

  condition {
    host_header {
      values = [var.ai_host]  # AI 서비스에 대한 호스트명을 지정합니다.
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ai.arn  # AI 대상 그룹으로 트래픽 포워딩
  }
}