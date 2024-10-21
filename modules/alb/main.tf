# # fe, be, ai 로드밸런서
# resource "aws_lb" "this" {
#   name       = "${var.lb_name}-jenkins-target-group"  # LB 이름과 함께 타겟 그룹 이름 설정
#   internal           = var.internal
#   load_balancer_type = "application"
#   security_groups    = var.security_group_ids
#   subnets            = var.subnet_ids
# }

# # jenkins 로드밸런서
# resource "aws_lb" "jenkins_lb" {
#   name       = "${var.lb_name}-jenkins-target-group"  # LB 이름과 함께 타겟 그룹 이름 설정
#   internal           = var.internal
#   load_balancer_type = "application"
#   security_groups    = var.security_group_ids
#   subnets            = var.subnet_ids
# }
# # jenkins 타겟 그룹
# resource "aws_lb_target_group" "jk" {
#   name       = "jenkins-target-group"
#   port       = 80
#   protocol   = "HTTP"
#   vpc_id     = var.vpc_id
#   target_type = "instance"
# }
# # Jenkins ALB의 HTTP 리스너 설정
# resource "aws_lb_listener" "https_jk" {
#   load_balancer_arn = aws_lb.jenkins_lb.arn  # ALB의 ARN을 지정하여 리스너를 연결
#   port              = 8080              # HTTP 포트를 통해 트래픽 수신
#   protocol          = "HTTP"           # HTTP 프로토콜 사용

#   # 기본 동작으로 jk 대상 그룹으로 트래픽 전달
#   default_action {
#     type             = "forward"       # 트래픽의 방향 설정
#     target_group_arn = aws_lb_target_group.jk.arn  # 기본 대상 그룹 지정 
#   }
# }
# # Jenkins 서비스로의 트래픽 라우팅 규칙
# resource "aws_lb_listener_rule" "jk_rule" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 100

#   condition {
#     host_header {
#       values = [var.jenkins_host]
#     }
#   }
  
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.jk.arn
#   }
# }


# resource "aws_lb_target_group" "be" {
#   name       = "be-target-group"
#   port       = 80
#   protocol   = "HTTP"
#   vpc_id     = var.vpc_id
#   target_type = "instance"
# }

# resource "aws_lb_target_group" "fe" {
#   name       = "fe-target-group"
#   port       = 80
#   protocol   = "HTTP"
#   vpc_id     = var.vpc_id
#   target_type = "instance"
# }

# resource "aws_lb_target_group" "ai" {
#   name       = "ai-target-group"
#   port       = 80  # AI 서비스에서 사용하는 포트. 필요에 따라 조정해야 합니다.
#   protocol   = "HTTP"  # AI 서비스에서 사용하는 프로토콜
#   vpc_id     = var.vpc_id
#   target_type = "instance"  # 기본 설정으로, AI 서비스가 EC2 인스턴스로 호스팅될 경우
# }

# # ALB의 HTTP 리스너 설정
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.this.arn  # ALB의 ARN을 지정하여 리스너를 연결
#   port              = 80               # HTTP 포트를 통해 트래픽 수신
#   protocol          = "HTTP"           # HTTP 프로토콜 사용

#   # 기본 동작으로 BE 대상 그룹으로 트래픽 전달
#   default_action {
#     type             = "forward"       # 트래픽의 방향 설정
#     target_group_arn = aws_lb_target_group.be.arn  # 기본 대상 그룹 지정 
#   }
# }

# # FE 서비스로의 트래픽 라우팅 규칙
# resource "aws_lb_listener_rule" "fe_rule" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 200

#   condition {
#     host_header {
#       values = [var.frontend_host]
#     }
#   }

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.fe.arn
#   }
# }

# # BE 서비스로의 트래픽 라우팅 규칙
# resource "aws_lb_listener_rule" "be_rule" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 100

#   condition {
#     host_header {
#       values = [var.backend_host]
#     }
#   }
  
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.be.arn
#   }
# }

# # AI 서비스로의 트래픽 라우팅 규칙
# resource "aws_lb_listener_rule" "ai_rule" {
#   listener_arn = aws_lb_listener.http.arn  # 기존 ALB 리스너과 같은 ARN
#   priority     = 300  # 다른 규칙과의 우선 순위를 조정하기 위해 설정

#   condition {
#     host_header {
#       values = [var.ai_host]  # AI 서비스에 대한 호스트명을 지정합니다.
#     }
#   }

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.ai.arn  # AI 대상 그룹으로 트래픽 포워딩
#   }
# }

# Jenkins 로드밸런서
resource "aws_lb" "jenkins_lb" {
  name               = "${var.lb_name}-jenkins"  # Jenkins ALB 이름 설정
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
}

# Jenkins 타겟 그룹
resource "aws_lb_target_group" "jenkins_target_group" {
  name       = "jenkins-target-group"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc_id
  target_type = "instance"
}

# Jenkins ALB의 HTTP 리스너 설정
resource "aws_lb_listener" "jenkins_listener" {
  load_balancer_arn = aws_lb.jenkins_lb.arn  # Jenkins ALB의 ARN을 지정
  port              = 8080                    # 트래픽 수신 포트
  protocol          = "HTTP"                  

  default_action {
    type             = "forward"              
    target_group_arn = aws_lb_target_group.jenkins_target_group.arn  # 기본 타겟 그룹
  }
}

# FE, BE, AI 로드밸런서
resource "aws_lb" "main_lb" {
  name               = "${var.lb_name}-main"  # Main ALB 이름 설정
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
}

# BE 및 FE 타겟 그룹
resource "aws_lb_target_group" "be_target_group" {
  name       = "be-target-group"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_target_group" "fe_target_group" {
  name       = "fe-target-group"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc_id
  target_type = "instance"
}

# ALB의 HTTP 리스너 설정
resource "aws_lb_listener" "main_listener" {
  load_balancer_arn = aws_lb.main_lb.arn 
  port              = 80                     
  protocol          = "HTTP"               

  default_action {
    type             = "forward"       
    target_group_arn = aws_lb_target_group.be_target_group.arn  # 기본 대상 그룹 지정
  }
}

# FE 서비스로의 트래픽 라우팅 규칙
resource "aws_lb_listener_rule" "fe_rule" {
  listener_arn = aws_lb_listener.main_listener.arn 
  priority     = 200

  condition {
    host_header {
      values = [var.frontend_host]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fe_target_group.arn
  }
}

# BE 서비스로의 트래픽 라우팅 규칙
resource "aws_lb_listener_rule" "be_rule" {
  listener_arn = aws_lb_listener.main_listener.arn
  priority     = 100

  condition {
    host_header {
      values = [var.backend_host]
    }
  }
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.be_target_group.arn
  }
}

# AI 서비스로의 트래픽 라우팅 규칙
resource "aws_lb_listener_rule" "ai_rule" {
  listener_arn = aws_lb_listener.main_listener.arn  
  priority     = 300  

  condition {
    host_header {
      values = [var.ai_host]  
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ai.arn  
  }
}
