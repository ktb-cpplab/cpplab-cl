# 기존의 개별 컨테이너 변수들을 하나의 컨테이너 목록 변수로 대체합니다.
variable "containers" {
  description = "태스크에 대한 컨테이너 정의 목록"
  type = list(object({
    name            = string
    image           = string
    memory          = number
    cpu             = number
    essential       = bool
    portMappings    = optional(list(object({
      containerPort = number
      hostPort      = number
      protocol      = string
    })), [])
    secrets         = optional(list(object({
      name      = string
      valueFrom = string
    })), [])
  }))
}

variable "load_balancers" {
  description = "로드 밸런서 구성의 목록"
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
}

# 기존의 단일 컨테이너 관련 변수들은 제거합니다.
# 제거할 변수들:
# - container_name
# - container_image
# - memory
# - cpu
# - container_port
# - host_port
# - secrets

# 나머지 변수들은 그대로 둡니다.
variable "task_family" {
  description = "ECS 태스크 정의 패밀리 이름"
  type        = string
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
  description = "Application Load Balancer와 연관된 타겟 그룹 ARN"
  type        = string
}

variable "cluster_id" {
  description = "ECS 클러스터 ID"
  type        = string
}

variable "cluster_name" {
  description = "ECS 클러스터 이름"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS 태스크 실행에 필요한 IAM 역할 ARN"
  type        = string
}

variable "network_mode" {
  description = "네트워크 모드"
  type        = string
  default     = "bridge"
}

# Auto Scaling 관련 변수들은 그대로 둡니다.
variable "min_capacity" {
  description = "Auto Scaling을 위한 최소 태스크 수"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Auto Scaling을 위한 최대 태스크 수"
  type        = number
  default     = 2
}

variable "memory_utilization_target" {
  description = "Auto Scaling을 위한 메모리 사용률 목표치"
  type        = number
  default     = 70.0
}

variable "scale_in_cooldown" {
  description = "스케일 인 쿨다운 기간"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "스케일 아웃 쿨다운 기간"
  type        = number
  default     = 300
}

variable "placement_constraints" {
  description = "ECS 서비스에 적용할 태스크 배치 제약 조건"
  type = list(object({
    type       = string
    expression = string
  }))
  default = []
}