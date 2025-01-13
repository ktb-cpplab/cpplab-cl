module "auto_scaling_be" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-be"
  instance_ami               = var.be_ami
  ecs_cluster_name           = module.ecs_cluster.cluster_name
  instance_type              = var.be_instance_type
  associate_public_ip_address = false
  launch_heartbeat_timeout  = var.launch_heartbeat_timeout
  terminate_heartbeat_timeout = var.terminate_heartbeat_timeout
  security_group_ids         = [module.auto_scaling_be_security_group.security_group_id]
  subnet_ids = module.vpc.private_subnet_ids
  key_name                   = var.key_name
  desired_capacity           = var.asg_desired_capacity
  max_size                   = var.asg_max_size
  min_size                   = var.asg_min_size
  target_group_arns          = [module.target_group["Backend"].target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "Backend"
  ecs_instance_type           = "be"

  depends_on = [module.ssm_iam_role]
}

module "auto_scaling_fe" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-fe"
  instance_ami               = var.instance_ami
  ecs_cluster_name           = module.ecs_cluster.cluster_name
  instance_type              = var.fe_instance_type
  associate_public_ip_address = true
  security_group_ids         = [module.auto_scaling_fe_security_group.security_group_id]
  subnet_ids = module.vpc.public_subnet_ids
  key_name                   = var.key_name
  desired_capacity           = var.asg_desired_capacity
  max_size                   = var.asg_max_size
  min_size                   = var.asg_min_size
  target_group_arns          = [module.target_group["Frontend"].target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "Frontend"
  ecs_instance_type           = "fe"

  depends_on = [module.ssm_iam_role]
}

module "auto_scaling_ai" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-ai"
  instance_ami               = var.instance_ami
  ecs_cluster_name           = module.ecs_cluster.cluster_name
  instance_type              = var.ai_instance_type
  associate_public_ip_address = false
  security_group_ids         = [module.auto_scaling_ai_security_group.security_group_id]
  subnet_ids = module.vpc.private_subnet_ids
  key_name                   = var.key_name
  desired_capacity           = var.asg_desired_capacity
  max_size                   = var.asg_max_size
  min_size                   = var.asg_min_size
  target_group_arns          = [module.target_group["ai1"].target_group_arn, module.target_group["ai2"].target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "AI"
  ecs_instance_type           = "ai"

  depends_on = [module.ssm_iam_role]
}