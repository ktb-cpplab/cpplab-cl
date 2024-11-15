variable "name" {
  type = string
}

variable "port" {
  type = number
}

variable "protocol" {
  type = string
  default = "HTTP"
}

variable "vpc_id" {
  type = string
}

variable "target_type" {
  type = string
  default = "instance"
}

variable "health_check_path" {
  type = string
  default = "/"
}