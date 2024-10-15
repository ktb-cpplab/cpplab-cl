output "launch_template_id" {
  value = aws_launch_template.this.id
}

output "autoscaling_group_id" {
  value = aws_autoscaling_group.this.id
}
