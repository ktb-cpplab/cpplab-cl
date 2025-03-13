variable "name" {
  type = string
}

variable "port" {
  type = number
}

variable "protocol" {
  type    = string
  default = "HTTP"
}

variable "vpc_id" {
  type = string
}

variable "target_type" {
  type    = string
  default = "instance"
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "interval" {
  type    = number
}

variable "timeout" {
  type    = number
}

variable "healthy_threshold" {
  type    = number
}

variable "unhealthy_threshold" {
  type    = number
}

variable "matcher" {
  type    = string
  default = "200"
}

variable "enable_health_check" {
  type    = bool
  default = true
}

variable "health_check_port" {
  type    = string
  default = "traffic-port"
}

variable "health_check_protocol" {
  type    = string
  default = "HTTP"
}

variable "deregistration_delay" {
  description = "The amount of time for the load balancer to wait before deregistering a target"
  type        = number
  default     = 300
}

variable "stickiness_enabled" {
  description = "Enable stickiness for the target group"
  type        = bool
  default     = false
}

variable "stickiness_type" {
  description = "Type of stickiness (app_cookie, lb_cookie, or source_ip)"
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_cookie_duration" {
  description = "Duration for stickiness in seconds"
  type        = number
  default     = 86400
}


variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
}
