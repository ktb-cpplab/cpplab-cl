variable "name_prefix" {
  description = "Prefix for the launch template and ASG"
  type        = string
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

variable "tag_name" {
  description = "Name tag for instances"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile for EC2 instances (optional)"
  type        = string
  default     = null  # 기본값을 null로 설정
}

variable "ecs_instance_type" {
  description = "ECS 인스턴스 타입을 지정 (fe, be, ai 등)"
  type        = string
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