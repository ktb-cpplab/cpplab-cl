module "ssm_iam_role" {
  source             = "./modules/iam-role"
  role_name          = "ssm-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
  ]
  policy_statements = [
    {
      Effect   = "Allow",
      Action   = ["autoscaling:DescribeAutoScalingGroups", "autoscaling:UpdateAutoScalingGroup"],
      Resource = "*"
    }
  ]
  tags = {
    Environment = "dev"
  }
}

module "ecs_execution_role" {
  source             = "./modules/iam-role"
  role_name          = "ecs-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
  policy_statements = [
    {
      Effect   = "Allow",
      Action   = ["ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability"],
      Resource = "arn:aws:ecr:ap-northeast-2:account-id:repository/repository-name"
    }
  ]
  tags = {
    Environment = "prod"
  }
}

output "ecs_execution_role_arn" {
  value = module.ecs_execution_role.role_arn
}