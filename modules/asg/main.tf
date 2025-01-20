resource "aws_launch_template" "this" {
  name        = var.launch_template_use_name_prefix ? null : var.launch_template_name
  name_prefix = var.launch_template_use_name_prefix ? "${var.launch_template_name}-" : null
  image_id      = var.instance_ami
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = var.security_group_ids  // 변경
  }

  key_name = var.key_name
  user_data     = var.user_data
  
  # 조건부로 IAM 인스턴스 프로파일 추가
  iam_instance_profile {
    name = var.iam_instance_profile != null ? var.iam_instance_profile : null
  }

  dynamic "tag_specifications" {
    for_each = var.tag_specifications
    content {
      resource_type = tag_specifications.value.resource_type
      tags          = merge(var.tags, tag_specifications.value.tags)
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name        = var.use_name_prefix ? null : var.name
  name_prefix = var.use_name_prefix ? "${var.name}-" : null
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.subnet_ids
  target_group_arns    = var.target_group_arns
  protect_from_scale_in    = var.protect_from_scale_in
  health_check_grace_period = var.health_check_grace_period

  # Mixed Instances Policy 추가
  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity # 온디맨드 최소 용량
      on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity # 온디맨드 비율
      spot_allocation_strategy                 = var.spot_allocation_strategy # 스팟 할당 전략 (capacity-optimized 추천)
      spot_instance_pools                      = var.spot_instance_pools # 여러 Spot 풀을 사용할 경우 설정
      spot_max_price                           = var.spot_max_price # Spot 최대 가격 (선택 사항)
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.this.id
        version            = "$Latest"
      }

      # 여러 인스턴스 유형을 지원하려면 override 추가
      # override {
      #   instance_type = "t3.micro"
      # }
    }
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
