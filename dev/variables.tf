variable "environment" {
  description = "Environment (e.g. dev, prod)"
  default     = "dev"
}

variable "project" {
  description = "Project name"
  default     = "cpplab"
}

################################################################################
# tag
################################################################################
variable "common_tags" {
  description = "Common tags applied to all resources"
  type = map(string)
  default = {
    Project     = "myproject"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

variable "region" {
  description = "AWS region"
  default     = "ap-northeast-2"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "192.170.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR block"
  default     = "192.170.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private Subnet CIDR block"
  default     = "192.170.2.0/24"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b"]
}

variable "key_name" {
  description = "Key pair for EC2 instances"
  default     = "cpplab-keypair"
}

variable "instance_type" {
  description = "Default instance type"
  default     = "t2.micro"
}

variable "mt_instance_type" {
  description = "Default instance type"
  default     = "t3a.micro"
}

variable "ai_instance_type" {
  description = "Default instance type"
  default     = "t3a.large"
}

variable "be_instance_type" {
  description = "Default instance type"
  default     = "t3a.medium"
}

variable "fe_instance_type" {
  description = "Default instance type"
  default     = "t2.meicro"
}

variable "jenkins_instance_type" {
  description = "Default instance type"
  default     = "t2.meicro"
}

variable "nat_ami" {
  description = "AMI ID for NAT Instance"
  default     = "ami-0e0ce674db551c1a5"
}

variable "jenkins_ami" {
  description = "AMI ID for Jenkins Instance"
  default     = "ami-04f296fcc99bb3bfc"
}

variable "instance_ami" {
  description = "AMI ID for Frontend Instances"
  default     = "ami-062cf18d655c0b1e8"
}

variable "be_ami" {
  description = "AMI ID for Backend Instances"
  default     = "ami-008826d9fbd497026"
}

variable "redis_ami" {
  description = "AMI ID for Redis (EC2) Instance"
  default     = "ami-01ce306e867ff466f"
}

variable "mt_ami" {
  description = "AMI ID for Monitoring Instance"
  default = "ami-"
}

variable "security_group_id" { 
  description = "Security Group ID for the EC2 instance"
  type        = string
}

variable "nat_instance_type" { 
  description = "Instance type for the NAT instance"
  type        = string
  default     = "t2.micro"
}

variable "tags" {
  description = "Default tags for resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Project     = "cpplab"
  }
}

################################################################################
# ASG.tf
################################################################################
variable "asg_desired_capacity" {
  description = "Auto Scaling 그룹의 원하는 인스턴스 수"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Auto Scaling 그룹의 최대 인스턴스 수"
  type        = number
  default     = 2
}

variable "asg_min_size" {
  description = "Auto Scaling 그룹의 최소 인스턴스 수"
  type        = number
  default     = 1
}
variable "on_demand_base_capacity" {
  description = "On-Demand Capacity"
  type        = number
  default     = 0
}
variable "on_demand_percentage_above_base_capacity" {
  description = "On-Demand Percentage Above Base Capacity"
  type        = number
  default     = 0
  
}
variable "spot_allocation_strategy" {
  description = "Spot Allocation Strategy"
  type        = string
  default     = "capacity-optimized"
}
variable "spot_instance_pools" {
  description = "Spot Instance Pools"
  type        = number
  default     = 2
}


################################################################################
# security-group
################################################# 
# 관리자 IP 목록
variable "admin_cidr_blocks" {
  description = "List of CIDR blocks for admin access"
  type        = list(string)
  default     = []
}

################################################################################
# acm.tf
################################################################################
variable "existing_zone_id" {
  description = "The ID of the existing Route 53 Hosted Zone"
  type        = string
}

variable "domain_name" {
  description = "The domain name for ACM validation"
  type        = string
}

################################################################################
# alb.tf
################################################################################

variable "alb_jenkins_name" {
  description = "Application Load Balancer name for Jenkins"
  default     = "alb-jenkins"
}

variable "alb_fe_name" {
  description = "Application Load Balancer name for Frontend"
  default     = "alb-fe"
}

variable "alb_main_name" {
  description = "Application Load Balancer name for Main"
  default     = "alb-main"
}

variable "tg_jenkins_name" {
  description = "Target Group name for Jenkins"
  default     = "tg-jenkins"
}

variable "tg_fe_name" {
  description = "Target Group name for Frontend"
  default     = "tg-fe"
}

variable "tg_be_name" {
  description = "Target Group name for Backend"
  default     = "tg-be"
}

variable "tg_ai1_name" {
  description = "Target Group name for AI1"
  default     = "tg-ai1"
}

variable "tg_ai2_name" {
  description = "Target Group name for AI2"
  default     = "tg-ai2"
}

variable "be_path_patterns" {
  description = "Path patterns for Backend"
  type        = list(string)
  default     = ["/api/*"]
}

variable "ai1_path_patterns" {
  description = "Path patterns for AI1"
  type        = list(string)
  default     = ["/ai1/*"]
}

variable "ai2_path_patterns" {
  description = "Path patterns for AI2"
  type        = list(string)
  default     = ["/ai2/*"]
}


################################################################################
# parameters.tf
################################################################################
variable "ssm_parameters" {
  type = map(object({
    value = string
    type  = string
  }))
  description = "Map of SSM parameters with their values and types"
}

################################################################################
# RDS.tf
################################################################################

variable "db_password" {
  description = "DB password"
  type        = string
}

################################################################################
# ECS.tf
################################################################################
variable "ecs_frontend_config" {
  description = "Configuration for frontend ECS service"
  type = object({
    task_family_name   = string
    service_name       = string
    desired_count      = number
    containers         = list(object({
      name         = string
      image        = string
      memory       = number
      cpu          = number
      essential    = bool
      portMappings = list(object({
        containerPort = number
        hostPort      = number
        protocol      = string
      }))
      secrets = list(object({
        name      = string
        valueFrom = string
      }))
    }))
    capacity_provider = object({
      name                          = string
      managed_termination_protection = string
      maximum_scaling_step_size     = number
      minimum_scaling_step_size     = number
      scaling_status                = string
      target_capacity               = number
    })
  })
}

variable "ecs_backend_config" {
  description = "Configuration for backend ECS service"
  type = object({
    task_family_name   = string
    service_name       = string
    desired_count      = number
    containers         = list(object({
      name         = string
      image        = string
      memory       = number
      cpu          = number
      essential    = bool
      portMappings = list(object({
        containerPort = number
        hostPort      = number
        protocol      = string
      }))
      secrets = list(object({
        name      = string
        valueFrom = string
      }))
    }))
    capacity_provider = object({
      name                          = string
      managed_termination_protection = string
      maximum_scaling_step_size     = number
      minimum_scaling_step_size     = number
      scaling_status                = string
      target_capacity               = number
    })
  })
}

variable "ecs_ai_config" {
  description = "Configuration for ai ECS service"
  type = object({
    task_family_name   = string
    service_name       = string
    desired_count      = number
    containers         = list(object({
      name         = string
      image        = string
      memory       = number
      cpu          = number
      essential    = bool
      portMappings = list(object({
        containerPort = number
        hostPort      = number
        protocol      = string
      }))
      secrets = list(object({
        name      = string
        valueFrom = string
      }))
    }))
    capacity_provider = object({
      name                          = string
      managed_termination_protection = string
      maximum_scaling_step_size     = number
      minimum_scaling_step_size     = number
      scaling_status                = string
      target_capacity               = number
    })
  })
}

variable "capacity_providers" {
  description = "Configuration for all ECS capacity providers"
  type = map(object({
    name                           = string
    managed_termination_protection = string
    maximum_scaling_step_size      = number
    minimum_scaling_step_size      = number
    scaling_status                 = string
    target_capacity                = number
  }))
}

