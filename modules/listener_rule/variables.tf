variable "listener_arn" {
  type = string
}

variable "priority" {
  type = number
}

variable "path_patterns" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
}