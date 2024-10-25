variable "task_family" {
  description = "ECS 태스크 정의 패밀리 이름"
  type        = string
}

variable "container_name" {
  description = "컨테이너 이름"
  type        = string
}

variable "container_image" {
  description = "컨테이너 이미지"
  type        = string
}

variable "memory" {
  description = "컨테이너 메모리"
  type        = number
}

variable "cpu" {
  description = "컨테이너 CPU 유닛"
  type        = number
}

variable "container_port" {
  description = "컨테이너 포트"
  type        = number
}

variable "host_port" {
  description = "호스트 포트"
  type        = number
}

variable "service_name" {
  description = "ECS 서비스 이름"
  type        = string
}

variable "desired_count" {
  description = "원하는 실행 중인 태스크 수"
  type        = number
}

variable "subnet_ids" {
  description = "ECS 서비스가 배포될 서브넷 ID 리스트"
  type        = list(string)
}

variable "security_group_ids" {
  description = "ECS 서비스에 사용할 보안 그룹 ID 리스트"
  type        = list(string)
}

variable "target_group_arn" {
  description = "Application Load Balancer와 연관된 타겟 그룹 ARN" # ALB와의 연결에 사용할 타겟 그룹 ARN
  type        = string               # 문자열 타입
}

variable "cluster_id" {
  description = "ECS 클러스터 ID"  # 클러스터 ID를 인수로 받습니다.
  type        = string               # 문자열 타입
}