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

variable "redirect_protocol" {
  description = "Protocol for redirect action"
  type        = string
  default     = "HTTPS"
}

variable "redirect_port" {
  description = "Port for redirect action"
  type        = string
  default     = "443"
}

variable "redirect_status_code" {
  description = "Status code for redirect action"
  type        = string
  default     = "HTTP_301"
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
}
