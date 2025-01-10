resource "aws_ecs_task_definition" "this" {
  family                   = var.task_family
  network_mode             = var.network_mode
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    for container in var.containers : {
      name         = container.name
      image        = container.image
      memory       = container.memory
      cpu          = container.cpu
      essential    = container.essential
      portMappings = container.portMappings
      secrets      = container.secrets
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  
  # 각 서비스에 지정된 Capacity Provider 사용 설정
  capacity_provider_strategy {
    capacity_provider = var.part_capacity_provider  # 각 서비스용 Capacity Provider
    weight            = 1  # 해당 Capacity Provider에 부여하는 가중치
  }

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [1] : []
    content {
      subnets         = var.subnet_ids
      security_groups = var.security_group_ids
      assign_public_ip = false
    }
  }

  dynamic "load_balancer" {
    for_each =  distinct(var.load_balancers)
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${var.cluster_name}/${var.service_name}" # 클러스터와 서비스 이름을 여기에 입력
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on         = [aws_ecs_service.this]
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = var.service_name
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = 70
    scale_in_cooldown  = 30
    scale_out_cooldown = 30
  }
}

# scale-in 프로세스 모니터링
resource "aws_appautoscaling_policy" "scale_in_policy" {
  name               = "${var.service_name}-scale-in"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70  // CPU 사용률이 30% 이하로 떨어지면 축소
    scale_in_cooldown  = 30 // 축소 후 대기 시간 (초)
    scale_out_cooldown = 30 // 확장 후 대기 시간 (초)
  }
}