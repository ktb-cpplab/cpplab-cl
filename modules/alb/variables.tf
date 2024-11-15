variable "name" {
  type = string
}

variable "internal" {
  type    = bool
  default = false
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}