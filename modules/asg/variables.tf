variable "name" {
  description = "Name used across the resources created"
  type        = string
}

variable "use_name_prefix" {
  description = "Determines whether to use `name` as is or create a unique name beginning with the `name` as the prefix"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "The Base64-encoded user data to provide when launching the instance"
  type        = string
  default     = null
}

variable "instance_ami" {
  description = "AMI ID for the instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address"
  type        = bool
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Subnet ID for the network interface"
  type        = list(string)
}

variable "key_name" {
  description = "Key pair name"
  type        = string
}

variable "desired_capacity" {
  description = "Desired capacity for the ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum size for the ASG"
  type        = number
}

variable "min_size" {
  description = "Minimum size for the ASG"
  type        = number
}

variable "target_group_arns" {
  description = "List of Target Group ARNs"
  type        = list(string)
}
variable "tags" {
  type = map(string)
  default = {
    Name        = "example-asg"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

variable "tag_specifications" {
  description = "The tags to apply to the resources during launch"
  type        = list(any)
  default     = []
}

variable "launch_template_name" {
  description = "Name for the launch template"
  type        = string
}

variable "launch_template_use_name_prefix" {
  description = "Determines whether to use `launch_template_name` as is or create a unique name beginning with the `launch_template_name` as the prefix"
  type        = bool
  default     = true
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile for EC2 instances (optional)"
  type        = string
  default     = null  # 기본값을 null로 설정
}

variable "health_check_grace_period" {
  description = "The amount of time, in seconds, after an instance comes into service before checking its health."
  type        = number
  default     = 150  
}

variable "protect_from_scale_in" {
  description = "Boolean to enable/disable instance protection from scale-in for the Auto Scaling group."
  type        = bool
  default     = false 
}

variable "launch_heartbeat_timeout" {
  description = "The amount of time, in seconds, that can elapse before the lifecycle hook times out."
  type        = number
  default     = 3600
}

variable "notification_target_arn" {
  description = "The ARN of the notification target that Auto Scaling will use to notify you when an instance is in the transition state."
  type        = string
  default = null
}

variable "lifecycle_hook_role_arn" {
  description = "The ARN of the IAM role that allows the Auto Scaling group to publish lifecycle notifications to an SNS topic."
  type        = string
  default = null
}

variable "terminate_heartbeat_timeout" {
  description = "The amount of time, in seconds, that can elapse before the lifecycle hook times out."
  type        = number
  default     = 3600
}

# Spot 관련 변수 추가
variable "on_demand_base_capacity" {
  description = "온디맨드 인스턴스의 최소 용량"
  default     = 0
}

variable "on_demand_percentage_above_base_capacity" {
  description = "온디맨드 인스턴스의 비율"
  default     = 0
}

variable "spot_allocation_strategy" {
  description = "Spot 할당 전략 (capacity-optimized 또는 lowest-price)"
  #default     = "capacity-optimized"
  default     = "lowest-price"

}

variable "spot_instance_pools" {
  description = "Spot Instance 풀의 개수"
  default     = 2
}

variable "spot_max_price" {
  description = "Spot 최대 가격 (USD)"
  default     = null
}