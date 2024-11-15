# /modules/ecs/capacity_provider/variables.tf
variable "name" {
  description = "Name of the ECS Capacity Provider"
  type        = string
}

variable "auto_scaling_group_arn" {
  description = "ARN of the Auto Scaling group"
  type        = string
}

variable "managed_termination_protection" {
  description = "Termination protection for the managed scaling"
  type        = string
  default     = "ENABLED"
}

variable "maximum_scaling_step_size" {
  description = "Maximum step size for scaling"
  type        = number
  default     = 1
}

variable "minimum_scaling_step_size" {
  description = "Minimum step size for scaling"
  type        = number
  default     = 1
}

variable "scaling_status" {
  description = "Status of the managed scaling"
  type        = string
  default     = "ENABLED"
}

variable "target_capacity" {
  description = "Target capacity for scaling"
  type        = number
  default     = 100
}
