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