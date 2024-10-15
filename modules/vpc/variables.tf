variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "nat_ami" {
  description = "AMI ID for the NAT instance"
  type        = string
  default     = "ami-0e0ce674db551c1a5"  # NAT 인스턴스에 적합한 AMI 설정
}

variable "nat_instance_type" {
  description = "Instance type for the NAT instance"
  type        = string
  default     = "t2.micro"  # 비용 절약을 위한 적당한 인스턴스 타입 설정
}

variable "key_name" {
  description = "Key pair name for SSH access to the NAT instance"
  type        = string
}

variable "nat_security_group_id" {
  description = "NAT 인스턴스에 적용할 보안 그룹 ID"
  type        = string
}