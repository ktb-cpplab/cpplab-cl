variable "load_balancer_arn" {
  type = string
}

variable "port" {
  type = number
}

variable "protocol" {
  type = string
}

variable "target_group_arn" {
  type = string
  default = null
}

variable "redirect" {
  type = bool
  default = false
}

variable "certificate_arn" {
  type = string
  default = null
}
