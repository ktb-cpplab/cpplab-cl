output "role_name" {
  value = aws_iam_role.this.name
}

output "iam_role_arn" {
  value = aws_iam_role.this.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.this.name
}
