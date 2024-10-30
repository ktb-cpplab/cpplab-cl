resource "aws_ecs_task_definition" "this" {
  family                   = var.task_family
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  
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
    
    # 환경 변수 및 시크릿 추가
    environment = [
      {
        name  = "ENV_VAR_NAME"
        value = var.some_value
      }
    ]

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
