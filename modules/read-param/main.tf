# Parameter Store에서 값을 조회하는 모듈
variable "parameter_name" {
  description = "Name of the parameter to retrieve from Parameter Store"
  type        = string
}

data "aws_ssm_parameter" "this" {
  name            = var.parameter_name
  with_decryption = true
}

output "value" {
  value = data.aws_ssm_parameter.this.value
}