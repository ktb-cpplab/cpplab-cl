variable "role_name" {
  description = "IAM 역할의 이름"
  type        = string
}

variable "assume_role_policy" {
  description = "역할을 담당할 엔티티(주로 EC2, Lambda 등)에 대한 정책"
  type        = string
}

variable "policy_arns" {
  description = "연결할 정책 ARNs 목록"
  type        = list(string)
}

variable "tags" {
  description = "태그"
  type        = map(string)
  default     = {}
}