output "ecs_cluster_id" {
  description = "ECS 클러스터 ID"  # 클러스터 ID를 출력합니다.
  value       = var.cluster_id  # 부모 모듈에서 전달받은 클러스터 ID 사용
}

output "ecs_service_id" {
  description = "ECS 서비스 ID"  # 서비스의 ID를 출력합니다.
  value       = aws_ecs_service.this.id  # 'this'는 해당 모듈 내에 정의한 aws_ecs_service 리소스의 이름입니다.
}