resource "aws_lb_listener" "this" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.port
  protocol          = var.protocol

  dynamic "default_action" {
    for_each = var.redirect ? [1] : []
    content {
      type = "redirect"
      redirect {
        protocol    = "HTTPS"
        port        = "443"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.redirect ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = var.target_group_arn
    }
  }

  # HTTPS 리스너일 경우에만 ssl_policy와 certificate_arn 적용
  ssl_policy      = var.protocol == "HTTPS" && var.certificate_arn != null ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn = var.protocol == "HTTPS" ? var.certificate_arn : null
}