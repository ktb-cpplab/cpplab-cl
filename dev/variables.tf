# General settings
variable "Name" {
  description = "The name of the ECS service"
  type        = string
}

variable "key_name" {
  description = "Key pair for EC2 instances"
  type        = string
}

variable "nat_tags" {
  description = "A map of tags to add to the NAT instance"
  type        = map(string)
}

variable "region" {
  description = "AWS region"
  default     = "ap-northeast-2"
}

# VPC settings
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones in the region"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnet CIDR blocks"
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of public subnet CIDR blocks"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT gateway"
  type        = bool
}

variable "enable_vpn_gateway" {
  description = "Whether to enable VPN gateway"
  type        = bool
}

variable "nat_instance_ami" {
  description = "The AMI ID for the NAT instance"
  type        = string
}

variable "nat_instance_type" {
  description = "The instance type for the NAT instance"
  type        = string
}

variable "vpc_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
}

# ASG settings
variable "ecs_instance_type" {
  description = "The instance type for the ECS instances"
  type        = string
}

# ECS settings
variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "ecs_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# ECS service settings
variable "frontend_service_name" {
  description = "The name of the frontend ECS service"
  type        = string
}

variable "frontend_port" {
  description = "The port for the frontend service"
  type        = number
  default     = 3000
}

variable "frontend_image" {
  description = "The ECR image for the frontend service"
  type        = string
}

variable "frontend_tags" {
  description = "Tags to apply to frontend resources"
  type        = map(string)
  default     = {}
}

variable "backend_service_name" {
  description = "The name of the backend ECS service"
  type        = string
}

variable "backend_image" {
  description = "The Docker image for the backend service"
  type        = string
}

variable "backend_port" {
  description = "The port on which the backend service listens"
  type        = number
}

variable "backend_tags" {
  description = "Tags to apply to backend resources"
  type        = map(string)
  default     = {}
}

# ALB settings
variable "frontend_alb_name" {
  description = "The name of the frontend ALB"
  type        = string
}

variable "backend_alb_name" {
  description = "The name of the backend ALB"
  type        = string
}

variable "frontend_target_group" {
  description = "The name of the frontend target group"
  type        = string
}

variable "backend_target_group" {
  description = "The name of the backend target group"
  type        = string
}

# ECR settings
variable "frontend_repository_name" {
  description = "The name of the frontend ECR repository"
  type        = string
}

variable "backend_repository_name" {
  description = "The name of the backend ECR repository"
  type        = string
}

variable "repository_read_write_access_arns" {
  description = "List of ARNs with read/write access to the repository"
  type        = list(string)
}

# ECR lifecycle policy settings
variable "tag_status" {
  description = "The tag status for the lifecycle policy"
  type        = string
  default     = "any"
}

variable "tag_prefix_list" {
  description = "The tag prefix list for the lifecycle policy"
  type        = list(string)
  default     = []
}

variable "count_type" {
  description = "The count type for the lifecycle policy"
  type        = string
  default     = "imageCountMoreThan"
}

variable "count_number" {
  description = "The count number for the lifecycle policy"
  type        = number
  default     = 20
}

variable "action_type" {
  description = "The action type for the lifecycle policy"
  type        = string
  default     = "expire"
}

# Parameter Store settings
variable "parameter_store_keys" {
  description = "List of Parameter Store keys to fetch"
  type        = list(string)
  default     = []
}