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

variable "nat_ami" {
  description = "AMI ID for NAT Instance"
  default     = "ami-0e0ce674db551c1a5"
}

variable "jenkins_ami" {
  description = "AMI ID for Jenkins Instance"
  default     = "ami-0723dbf2481162caf"
}

variable "instance_ami" {
  description = "AMI ID for Backend/Frontend/Jenkins Instances"
  default     = "ami-062cf18d655c0b1e8"
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
