output "lb_arn" {
  value = aws_lb.this.arn
}

output "be_target_group_arn" {
  value = aws_lb_target_group.be.arn
}

output "fe_target_group_arn" {
  value = aws_lb_target_group.fe.arn
}
