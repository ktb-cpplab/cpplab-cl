variable "domain_name" {
  description = "ACM에 등록할 도메인 이름"
  type        = string
  default     = "cpplab.store"
}

variable "environment" {
  description = "환경 정보 (예: dev, prod)"
  type        = string
}