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
    echo "ECS_CLUSTER=${var.ecs_cluster_name}" >> /etc/ecs/ecs.config
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
  protect_from_scale_in    = var.protect_from_scale_in       # 변수로 인스턴스 축소 보호 설정
  health_check_grace_period = var.health_check_grace_period  # 변수로 상태 확인 유예 기간 설정
  
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