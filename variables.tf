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
  }
}

# Auto Scaling 그룹 변수
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


variable "certificate_arn" {
  description = "certificate_arn"
  type = string
  default = null
}