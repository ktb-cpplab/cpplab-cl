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
  default = 30
}

variable "timeout" {
  type    = number
  default = 5
}

variable "healthy_threshold" {
  type    = number
  default = 3
}

variable "unhealthy_threshold" {
  type    = number
  default = 3
}

variable "matcher" {
  type    = string
  default = "200"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
}
