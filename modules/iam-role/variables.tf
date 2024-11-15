variable "role_name" {
  description = "The name of the IAM role"
  type        = string
}

variable "assume_role_policy" {
  description = "The assume role policy document for the IAM role"
  type        = string
}

variable "policy_arns" {
  description = "List of ARN for managed policies to attach to the IAM role"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  type        = list(object({
    Effect   = string
    Action   = list(string)
    Resource = string
  }))
  default     = []
  description = "Inline policies for the IAM role"
}

variable "tags" {
  description = "Tags to assign to the IAM role"
  type        = map(string)
  default     = {}
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

variable "create_instance_profile" {
  description = "Whether to create an instance profile for the IAM role"
  type        = bool
  default     = false
}