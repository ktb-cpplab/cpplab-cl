resource "aws_lb" "this" {

  dynamic "access_logs" {
    for_each = var.access_logs != null && var.access_logs != {} ? [var.access_logs] : []
    content {
      bucket  = access_logs.value.bucket
      enabled = try(access_logs.value.enabled, true)
      prefix  = try(access_logs.value.prefix, null)
    }
  }

  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
  tags = merge(var.tags, {
    Name = var.name
  })
}
