resource "aws_lb_target_group" "this" {
  name        = var.name
  port        = var.port
  protocol    = var.protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  dynamic "health_check" {
    for_each = var.enable_health_check ? [1] : []
    content {
      enabled             = true
      healthy_threshold   = try(var.healthy_threshold, 3)
      interval            = try(var.interval, 30)
      matcher             = try(var.matcher, { http_code = "200" })
      path                = try(var.health_check_path, "/")
      port                = try(var.health_check_port, "traffic-port")
      protocol            = try(var.health_check_protocol, var.protocol)
      timeout             = try(var.timeout, 5)
      unhealthy_threshold = try(var.unhealthy_threshold, 2)
    }
  }

  deregistration_delay = try(var.deregistration_delay, 300) # 기본값 300초 설정

  dynamic "stickiness" {
    for_each = var.stickiness_enabled ? [1] : []
    content {
      enabled         = var.stickiness_enabled
      type            = var.stickiness_type
      cookie_duration = try(var.stickiness_cookie_duration, 86400) # 기본값 1일 설정
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })

  lifecycle {
    create_before_destroy = true
  }
}
