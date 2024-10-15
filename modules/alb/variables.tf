variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "internal" {
  description = "Boolean indicating whether the load balancer is internal"
  type        = bool
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
