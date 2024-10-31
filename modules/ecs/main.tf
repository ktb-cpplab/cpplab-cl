resource "aws_ecs_task_definition" "this" {
  family                   = var.task_family
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([{
    name      = var.container_name
    image     = var.container_image
    memory    = var.memory
    cpu       = var.cpu
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.host_port
      protocol      = "tcp"
    }]
    
    secrets = var.secrets
  }])
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_id    # 부모 모듈에서 전달받은 클러스터 ID 사용
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "EC2"

  # network_configuration 제거
  # network_configuration {
  #    subnets          = var.subnet_ids
  #    security_groups  = var.security_group_ids
  # }

  # ALB와 연결하는 설정
  load_balancer {
    target_group_arn = var.target_group_arn  # ALB 타겟 그룹 ARN
    container_name   = var.container_name    # ALB와 연결할 컨테이너 이름
    container_port   = var.container_port     # 컨테이너에서 사용하는 포트
  }

  #depends_on = [aws_ecs_cluster.this]
}


# ECS Service Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_capacity           # 최대 태스크 수
  min_capacity       = var.min_capacity           # 최소 태스크 수
  resource_id        = "service/${var.cluster_id}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on         = [aws_ecs_service.this]
}

# Target Tracking Scaling Policy for ECS Memory Utilization
resource "aws_appautoscaling_policy" "memory_target_tracking" {
  name                   = "${var.service_name}-memory-scaling-policy"
  resource_id            = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension     = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace      = aws_appautoscaling_target.ecs_target.service_namespace
  policy_type            = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value = var.memory_utilization_target  # 목표 메모리 사용률 (%)
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    scale_in_cooldown  = var.scale_in_cooldown    # 축소 휴지 기간
    scale_out_cooldown = var.scale_out_cooldown   # 확장 휴지 기간
  }
}