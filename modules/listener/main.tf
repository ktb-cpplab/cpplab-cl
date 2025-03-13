resource "aws_lb_listener" "this" {
  load_balancer_arn = var.load_balancer_arn
  port              = var.port
  protocol          = var.protocol

  # Default action 처리
  dynamic "default_action" {
    for_each = var.redirect ? [1] : []
    content {
      type = "redirect"
      redirect {
        protocol    = var.redirect_protocol    // 유연하게 설정 가능
        port        = var.redirect_port        // 기본값 "443"
        status_code = var.redirect_status_code // 기본값 "HTTP_301"
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

  # HTTPS 리스너 설정 (ssl_policy와 certificate_arn 유효성 검사)
  ssl_policy      = (var.protocol == "HTTPS" && var.certificate_arn != null) ? var.ssl_policy : null
  certificate_arn = var.protocol == "HTTPS" ? var.certificate_arn : null

  tags = var.tags
}