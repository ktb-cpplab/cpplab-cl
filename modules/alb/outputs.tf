output "lb_arn" {
  value = aws_lb.main_lb.arn
}

output "be_target_group_arn" {
  value = aws_lb_target_group.be.arn
}

output "fe_target_group_arn" {
  value = aws_lb_target_group.fe.arn
}

output "ai_target_group_arn" {
  value = aws_lb_target_group.ai.arn
}

output "jenkins-target-group" {
  value = aws_lb_target_group.jk.arn
}