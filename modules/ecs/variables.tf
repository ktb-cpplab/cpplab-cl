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

variable "cluster_name" {
  description = "ECS 클러스터 name"  # 클러스터 ID를 인수로 받습니다.
  type        = string               # 문자열 타입
}

variable "secrets" {
  description = "List of secrets to inject into the container"
  type        = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "some_value" {
  description = "An example value for the environment variable"
  type        = string
  default     = "default_value"  # 필요에 따라 기본값 설정
}

variable "execution_role_arn" {
  description = "IAM role ARN for ECS task execution"
  type        = string
}


variable "max_task_count" {
  default = 2  # 최대 태스크 수
}

variable "min_task_count" {
  default = 1  # 최소 태스크 수
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks for auto-scaling"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks for auto-scaling"
  type        = number
  default     = 2
}

variable "memory_utilization_target" {
  description = "Memory utilization target for auto-scaling"
  type        = number
  default     = 70.0
}

variable "scale_in_cooldown" {
  description = "Cooldown period for scale-in"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Cooldown period for scale-out"
  type        = number
  default     = 300
}

variable "network_mode" {
  description = "network_mode"
  type        = string
  default     = "bridge"
}

