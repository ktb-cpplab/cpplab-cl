variable "vpc_id" {
  description = "The VPC ID where the resources will be created"
  type        = string
}

variable "name" {
  description = "Name for the security group"
  type        = string
}

variable "ingress_rules" {
  description = "보안 그룹의 인그레스 규칙 목록"
  type        = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = []
}

variable "egress_rules" {
  description = "보안 그룹의 이그레스 규칙 목록"
  type        = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string))
    security_groups = optional(list(string))
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}