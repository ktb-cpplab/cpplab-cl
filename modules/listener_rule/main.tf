resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = var.priority

  condition {
    path_pattern {
      values = var.path_patterns
    }
  }

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
  tags = var.tags
}