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

variable "frontend_host" {
  description = "Host header for frontend routing"
  type        = string
  default     = "frontend.example.com"
}

variable "backend_host" {
  description = "Host header for backend routing"
  type        = string
  default     = "backend.example.com"
}

variable "ai_host" {
  description = "Host header for AI service routing"
  type        = string
  default     = "ai.example.com"
}

variable "jenkins_host" {
  description = "Host header for jenkins service routing"
  type        = string
  default     = "jk.example.com"
}

variable "deregistration_delay_time" {
  description = "deregistration_delay_time"
  type        = string
  default     = "60"
}