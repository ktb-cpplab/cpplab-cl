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
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/AutoScalingFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
  tags = {
    Environment = var.environment
  }
  create_instance_profile = true
}

module "ecs_execution_role" {
  source             = "./modules/iam-role"
  role_name          = "ecs_execution_role"
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
  policy_arns = []
  inline_policies = [
    {
      Effect   = "Allow",
      Action   = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      Resource = "*"
    }
  ]
  tags = {
    Environment = var.environment
  }
}

module "mt_role" {
  source             = "./modules/iam-role"
  role_name          = "mt-role"
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
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  ]
  inline_policies = [
    {
      Effect   = "Allow"
      Action   = [
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenDataChannel",
        "ssmmessages:SendDataChannel",
        "ssmmessages:ReceiveDataChannel"
      ]
      Resource = "*"
    },
    {
      Effect   = "Allow"
      Action   = [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2:DescribeRegions"
      ]
      Resource = "*"
    },
    {
      Effect   = "Allow"
      Action   = [
        "ec2:DescribeNetworkInterfaces"
      ]
      Resource = "*"
    }
  ]
  tags = {
    Environment = var.environment
  }
  create_instance_profile = true
}
