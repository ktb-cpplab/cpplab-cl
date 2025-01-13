variable "domain_name" {
  description = "Route 53에서 관리할 도메인 이름"
  type        = string
}

variable "domain_validation_options" {
  description = "ACM 인증서에서 반환된 도메인 검증 옵션"
  type        = list(object({
    domain_name            = string
    resource_record_name   = string
    resource_record_type   = string
    resource_record_value  = string
  }))
}

variable "additional_records" {
  description = "Route 53에 추가적으로 생성할 DNS 레코드"
  type        = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
}
