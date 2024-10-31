# Parameter Store에서 값을 갱신하는 모듈
resource "aws_ssm_parameter" "update" {
  name      = var.parameter_name
  type      = "String"
  value     = var.new_value
}

output "updated_value" {
  value = aws_ssm_parameter.update.value
}