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
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "key_name" {
  description = "Key pair for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Default instance type"
  type        = string
}

variable "mt_instance_type" {
  description = "Monitoring instance type"
  type        = string
}

variable "ai_instance_type" {
  description = "AI instance type"
  type        = string
}

variable "be_instance_type" {
  description = "Backend instance type"
  type        = string
}

variable "fe_instance_type" {
  description = "Frontend instance type"
  type        = string
}

variable "jenkins_instance_type" {
  description = "Jenkins instance type"
  type        = string
}

variable "nat_ami" {
  description = "AMI ID for NAT Instance"
  type        = string
}

variable "jenkins_ami" {
  description = "AMI ID for Jenkins Instance"
  type        = string
}

variable "instance_ami" {
  description = "AMI ID for Frontend Instances"
  type        = string
}

variable "be_ami" {
  description = "AMI ID for Backend Instances"
  type        = string
}

variable "redis_ami" {
  description = "AMI ID for Redis (EC2) Instance"
  type        = string
}

variable "mt_ami" {
  description = "AMI ID for Monitoring Instance"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID for the EC2 instance"
  type        = string
}

variable "nat_instance_type" {
  description = "Instance type for the NAT instance"
  type        = string
}

variable "tags" {
  description = "Default tags for resources"
  type        = map(string)
}

variable "asg_desired_capacity" {
  description = "Auto Scaling 그룹의 원하는 인스턴스 수"
  type        = number
}

variable "asg_max_size" {
  description = "Auto Scaling 그룹의 최대 인스턴스 수"
  type        = number
}

variable "asg_min_size" {
  description = "Auto Scaling 그룹의 최소 인스턴스 수"
  type        = number
}

variable "certificate_arn" {
  description = "Certificate ARN for ACM"
  type        = string
}

########### backend.tf ###########
variable "tfbackend_bucket" {
  description = "S3 bucket name for Terraform state"
  type        = string
}

variable "tfbackend_key" {
  description = "Key for storing the Terraform state file in the S3 bucket"
  type        = string
}

variable "tfbackend_region" {
  description = "AWS region for the S3 bucket"
  type        = string
}

variable "tfbackend_dynamodb_table" {
  description = "DynamoDB table for Terraform state locking"
  type        = string
}

########### security_groups.tf ###########
variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed for ingress"
  type        = list(string)
}

variable "allowed_egress_cidr_blocks" {
  description = "List of CIDR blocks allowed for egress"
  type        = list(string)
}

variable "redis_ingress_security_groups" {
  description = "List of Security Group IDs allowed to access Redis"
  type        = list(string)
}

########### rds.tf ###########
# 기본 설정
variable "db_password_parameter_name" {
  description = "Parameter Store path for DB password"
  type        = string
}

variable "rds_subnet_group_name" {
  description = "Name of the RDS subnet group"
  type        = string
}

variable "rds_subnet_group_description" {
  description = "Description of the RDS subnet group"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

# RDS 설정
variable "allocated_storage" {
  description = "Allocated storage for the RDS instance in GB"
  type        = number
}

variable "engine" {
  description = "Database engine type"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "parameter_group_name" {
  description = "Parameter group name for the RDS instance"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs for the RDS instance"
  type        = list(string)
}

# 백업 및 유지 관리
variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
}

# variable "backup_window" {
#   description = "Backup window"
#   type        = string
# }

# variable "maintenance_window" {
#   description = "Maintenance window"
#   type        = string
# }

# 고가용성 및 성능
variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
}

variable "storage_type" {
  description = "Storage type for the RDS instance"
  type        = string
}

# variable "max_allocated_storage" {
#   description = "Maximum allocated storage for the RDS instance"
#   type        = number
# }

# 태그
variable "rds_instance_name" {
  description = "Name tag for the RDS instance"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, production)"
  type        = string
}

# Parameter Store
variable "db_url_parameter_name" {
  description = "Parameter Store path for DB URL"
  type        = string
}

variable "ai_db_url_parameter_name" {
  description = "Parameter Store path for AI DB URL"
  type        = string
}

########### iam_role.tf ###########
# 공통 변수
variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
}

# SSM IAM Role 변수
variable "ssm_iam_role_name" {
  description = "Name of the SSM IAM Role"
  type        = string
}

variable "ssm_assume_role_policy" {
  description = "Assume Role Policy for SSM IAM Role"
  type        = object({
    Version = string
    Statement = list(object({
      Action    = string
      Effect    = string
      Principal = object({ Service = string })
    }))
  })
}

variable "ssm_policy_arns" {
  description = "Policy ARNs for SSM IAM Role"
  type        = list(string)
}

# ECS Execution Role 변수
variable "ecs_execution_role_name" {
  description = "Name of the ECS Execution Role"
  type        = string
}

variable "ecs_assume_role_policy" {
  description = "Assume Role Policy for ECS Execution Role"
  type        = object({
    Version = string
    Statement = list(object({
      Action    = string
      Effect    = string
      Principal = object({ Service = string })
    }))
  })
}

variable "ecs_inline_policies" {
  description = "Inline policies for ECS Execution Role"
  type        = list(map(any))
}

# Monitoring Role (mt_role) 변수
variable "mt_role_name" {
  description = "Name of the Monitoring Role"
  type        = string
}

variable "mt_assume_role_policy" {
  description = "Assume Role Policy for Monitoring Role"
  type        = object({
    Version = string
    Statement = list(object({
      Action    = string
      Effect    = string
      Principal = object({ Service = string })
    }))
  })
}

variable "mt_policy_arns" {
  description = "Policy ARNs for Monitoring Role"
  type        = list(string)
}

variable "mt_inline_policies" {
  description = "Inline policies for Monitoring Role"
  type        = list(map(any))
}

variable "environment" {
  description = "Environment (e.g., dev, staging, production)"
  type        = string
}
