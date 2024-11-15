variable "role_name" {
  description = "The name of the IAM role"
  type        = string
}

variable "assume_role_policy" {
  description = "The assume role policy document JSON"
  type        = string
}

variable "policy_statements" {
  description = "List of inline policy statements for the role"
  type = list(object({
    Effect   = string
    Action   = any # 단일 문자열 또는 리스트 허용
    Resource = string
  }))
  default = []
}

variable "policy_arns" {
  description = "A list of IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the IAM role and instance profile"
  type        = map(string)
  default     = {}
}