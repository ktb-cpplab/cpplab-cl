variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "backend_bucket_name" {
  description = "백엔드로 사용할 S3 버킷의 이름"
  type        = string
}

variable "backend_table_name" {
  description = "백엔드 잠금을 위한 DynamoDB 테이블의 이름"
  type        = string
}

variable "environment" {
  description = "환경 (예: dev, staging, prod)"
  type        = string
  default     = "dev"
}