# 공통 User Data 및 기본 설정 정의
locals {
  user_data = base64encode(<<EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${module.ecs_cluster.cluster_name}" >> /etc/ecs/ecs.config
  EOF
  )

  # 네이밍 규칙 및 공통 설정
  common_settings = {
    be = {
      name                  = "${var.project}-${var.environment}-be"
      subnet_ids            = module.vpc.private_subnet_ids
      instance_ami          = var.be_ami
      instance_type         = var.be_instance_type
      user_data             = local.user_data
      associate_public_ip   = false
      security_group_ids    = [module.auto_scaling_be_security_group.security_group_id]
      role_tag              = "Backend"
      target_group_arns     = [module.target_group["Backend"].target_group_arn]
    }
    fe = {
      name                  = "${var.project}-${var.environment}-fe"
      subnet_ids            = module.vpc.public_subnet_ids
      instance_ami          = var.instance_ami
      instance_type         = var.fe_instance_type
      user_data             = local.user_data
      associate_public_ip   = true
      security_group_ids    = [module.auto_scaling_fe_security_group.security_group_id]
      role_tag              = "Frontend"
      target_group_arns     = [module.target_group["Frontend"].target_group_arn]
    }
    ai = {
      name                  = "${var.project}-${var.environment}-ai"
      subnet_ids            = module.vpc.private_subnet_ids
      instance_ami          = var.instance_ami
      instance_type         = var.ai_instance_type
      user_data             = local.user_data
      associate_public_ip   = false
      security_group_ids    = [module.auto_scaling_ai_security_group.security_group_id]
      role_tag              = "AI"
      target_group_arns     = [
        module.target_group["ai1"].target_group_arn,
        module.target_group["ai2"].target_group_arn
      ]
    }
  }
}

module "auto_scaling" {
  source = "./modules/asg"

  for_each = local.common_settings

  name                       = each.value.name
  subnet_ids                 = each.value.subnet_ids
  desired_capacity           = var.asg_desired_capacity
  max_size                   = var.asg_max_size
  min_size                   = var.asg_min_size
  target_group_arns          = each.value.target_group_arns
  on_demand_base_capacity    = var.asg_desired_capacity
  on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
  spot_allocation_strategy   = var.spot_allocation_strategy
  spot_instance_pools        = var.spot_instance_pools

  # Launch Template
  launch_template_name       = each.value.name
  instance_ami               = each.value.instance_ami
  instance_type              = each.value.instance_type
  user_data                  = each.value.user_data
  associate_public_ip_address = each.value.associate_public_ip
  security_group_ids         = each.value.security_group_ids
  key_name                   = var.key_name
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name

  # Tagging
  tag_specifications = [
    {
      resource_type = "instance"
      tags = merge(
        var.common_tags,
        { Role = each.value.role_tag, Service = each.value.name, Name = each.value.name }
      )
    }
  ]

  tags = merge(
    var.common_tags,
    { Role = each.value.role_tag, Service = each.value.name }
  )

  depends_on = [module.ssm_iam_role]
}
