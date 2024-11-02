variable "table_name" {
  description = "DynamoDB 테이블의 이름"
  type        = string
}

variable "billing_mode" {
  description = "과금 모드 (PROVISIONED 또는 PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "파티션 키의 이름"
  type        = string
}

variable "hash_key_type" {
  description = "파티션 키의 데이터 타입 (S, N, B)"
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "정렬 키의 이름 (옵션)"
  type        = string
  default     = null
}

variable "range_key_type" {
  description = "정렬 키의 데이터 타입 (S, N, B)"
  type        = string
  default     = "S"
}

variable "tags" {
  description = "태그 (키-값 쌍)"
  type        = map(string)
  default     = {}
}