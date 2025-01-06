module "ssm_iam_role" {
  source             = "./modules/iam-role"
  role_name          = var.ssm_iam_role_name
  assume_role_policy = jsonencode(var.ssm_assume_role_policy)
  policy_arns        = var.ssm_policy_arns
  tags = {
    Environment = var.environment
  }
  create_instance_profile = true
}

module "ecs_execution_role" {
  source             = "./modules/iam-role"
  role_name          = var.ecs_execution_role_name
  assume_role_policy = jsonencode(var.ecs_assume_role_policy)
  policy_arns        = []
  inline_policies    = var.ecs_inline_policies
  tags = {
    Environment = var.environment
  }
}

module "mt_role" {
  source             = "./modules/iam-role"
  role_name          = var.mt_role_name
  assume_role_policy = jsonencode(var.mt_assume_role_policy)
  policy_arns        = var.mt_policy_arns
  inline_policies    = var.mt_inline_policies
  tags = {
    Environment = var.environment
  }
  create_instance_profile = true
}
