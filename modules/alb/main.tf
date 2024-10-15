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
