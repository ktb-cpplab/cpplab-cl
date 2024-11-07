# 생성된 Launch Template의 ID
output "launch_template_id" {
  value = aws_launch_template.this.id
}

# 생성된 Auto Scaling 그룹의 ID
output "autoscaling_group_id" {
  value = aws_autoscaling_group.this.id
}

output "asg_arn" {
  value = aws_autoscaling_group.this.arn  # 실제 모듈 내의 리소스 이름으로 수정
}
