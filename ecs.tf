locals {
  auto_scaling_group_arns = {
    ai = module.auto_scaling_ai.asg_arn
    be = module.auto_scaling_be.asg_arn
    fe = module.auto_scaling_fe.asg_arn
  }
}


module "capacity_providers" {
  source = "./modules/ecs/capacity_provider"

  for_each = var.capacity_providers

  name                           = each.value.name
  auto_scaling_group_arn         = local.auto_scaling_group_arns[each.key]
  managed_termination_protection = each.value.managed_termination_protection
  maximum_scaling_step_size      = each.value.maximum_scaling_step_size
  minimum_scaling_step_size      = each.value.minimum_scaling_step_size
  scaling_status                 = each.value.scaling_status
  target_capacity                = each.value.target_capacity
}




# 생성된 Capacity Provider들을 ECS 클러스터에 연결
resource "aws_ecs_cluster_capacity_providers" "cluster_providers" {
  cluster_name       = module.ecs_cluster.cluster_name
  capacity_providers = values(module.capacity_providers)[*].name  # 모든 Capacity Provider 이름 연결
}

# ECS 모듈 호출
# AI 파트
module "ecs_ai" {
  source                     = "./modules/ecs"
  cluster_id                 = module.ecs_cluster.cluster_id
  cluster_name               = module.ecs_cluster.cluster_name
  task_family_name           = var.ecs_ai_config.task_family_name
  desired_count              = var.ecs_ai_config.desired_count
  subnet_ids                 = module.vpc.private_subnet_ids
  security_group_ids         = [module.auto_scaling_ai_security_group.security_group_id]
  service_name               = var.ecs_ai_config.service_name
  execution_role_arn         = module.ecs_execution_role.iam_role_arn
  part_capacity_provider     = module.capacity_providers["ai"].name  # AI 서비스의 Capacity Provider

  containers = var.ecs_ai_config.containers

  load_balancers = [
    {
      target_group_arn = module.target_group["ai1"].target_group_arn
      container_name   = "ai-container-peter"
      container_port   = 5000
    },
    {
      target_group_arn = module.target_group["ai2"].target_group_arn
      container_name   = "ai-container-simon"
      container_port   = 5001
    }
  ]
  depends_on = [ module.ecs_execution_role ]
}

# BE 파트
module "ecs_be" {
  source                     = "./modules/ecs"
  cluster_id                 = module.ecs_cluster.cluster_id
  cluster_name               = module.ecs_cluster.cluster_name
  task_family_name           = var.ecs_backend_config.task_family_name
  desired_count              = var.ecs_backend_config.desired_count
  subnet_ids                 = module.vpc.private_subnet_ids
  security_group_ids         = [module.auto_scaling_be_security_group.security_group_id]
  service_name               = var.ecs_backend_config.service_name
  execution_role_arn         = module.ecs_execution_role.iam_role_arn
  part_capacity_provider     = module.capacity_providers["be"].name  # BE 서비스의 Capacity Provider
  containers = var.ecs_backend_config.containers
  load_balancers = [
    {
      target_group_arn = module.target_group["Backend"].target_group_arn
      container_name   = var.ecs_backend_config.container_name
      container_port   = var.ecs_backend_config.container_port
    }
  ]
  depends_on = [ module.ecs_execution_role ]
}
# FE 파트
module "ecs_fe" {
  source                     = "./modules/ecs"
  cluster_id                 = module.ecs_cluster.cluster_id
  cluster_name               = module.ecs_cluster.cluster_name
  task_family_name           = var.ecs_frontend_config.task_family_name
  desired_count              = var.ecs_frontend_config.desired_count
  subnet_ids                 = module.vpc.public_subnet_ids
  security_group_ids         = [module.auto_scaling_fe_security_group.security_group_id]
  service_name               = var.ecs_frontend_config.service_name
  execution_role_arn         = module.ecs_execution_role.iam_role_arn
  part_capacity_provider     = module.capacity_providers["fe"].name  # FE 서비스의 Capacity Provider

  containers = var.ecs_frontend_config.containers
  load_balancers = [
    {
      target_group_arn = module.target_group["Frontend"].target_group_arn
      container_name   = var.ecs_frontend_config.container_name
      container_port   = var.ecs_frontend_config.container_port
    }
  ]
  depends_on = [ module.ecs_execution_role ]
}