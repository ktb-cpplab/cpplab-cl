resource "aws_launch_template" "this" {
  name_prefix   = var.name_prefix
  image_id      = var.instance_ami
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = var.security_group_ids  // 변경
  }

  key_name = var.key_name

  # User Data를 추가하여 인스턴스를 ECS 클러스터에 연결
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=cpplab-ecs-cluster" >> /etc/ecs/ecs.config
  EOF
  )
  
  # 조건부로 IAM 인스턴스 프로파일 추가
  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile != null ? [1] : []
    content {
      name = var.iam_instance_profile
    }
  }
  # 태그 스펙ification 추가
  tag_specifications {
    resource_type = "instance"

    tags = {
      "Name"              = var.tag_name
      "ecs.instance-type" = var.ecs_instance_type
    }
  }
}

resource "aws_autoscaling_group" "this" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.subnet_ids  // 여러 서브넷이 포함된 리스트
  target_group_arns    = var.target_group_arns
  # protect_from_scale_in 설정이 true로 되어 있으면 인스턴스가 보호되기 때문에 scale-in 이벤트에서 인스턴스가 종료되지 않습니다.
  protect_from_scale_in = true
  
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.tag_name
    propagate_at_launch = true
  }
}

# # ASG에 CPU 사용률 기반 Target Tracking Policy 추가
# resource "aws_autoscaling_policy" "cpu_target_tracking" {
#   autoscaling_group_name = aws_autoscaling_group.this.name
#   name                   = "cpu-target-tracking-policy"
#   policy_type            = "TargetTrackingScaling"
#   estimated_instance_warmup = 300  # 인스턴스가 추가된 후 안정화되는 데 필요한 시간 (초)

#   target_tracking_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ASGAverageCPUUtilization"  # ASG의 평균 CPU 사용률 기반
#     }
#     target_value = 70.0  # 목표 CPU 사용률 (%)
#   }
# }

#  CPU 사용률이 특정 임계값 이하로 떨어질 때 인스턴스를 축소하도록 설정
resource "aws_autoscaling_policy" "scale_in_policy" {
  autoscaling_group_name = aws_autoscaling_group.this.name
  name                   = "cpu-scale-in-policy"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 300  // 인스턴스가 추가된 후 안정화되는 데 필요한 시간 (초)

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"  // 평균 CPU 사용률에 기반
    }
    target_value = 30.0  // 목표 CPU 사용률 (%). 이 임계값 아래로 떨어지면 축소
    #scale_in_cooldown = 300  // 축소 후 대기 시간 (초)
  }
}
