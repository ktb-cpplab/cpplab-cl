module "ecs_asg_iam_role" {
  source = "./modules/iam-role"

  role_name = "ecs-asg-role"

  # Assume Role Policy
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  # 관리형 정책
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

  tags = merge(var.common_tags, { Name = "Launch Template IAM Role" })

  create_instance_profile = true
}

module "jenkins_iam_role" {
  source = "./modules/iam-role"

  role_name = "jenkins-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = merge(var.common_tags, { Name = "Jenkins IAM Role" })
  create_instance_profile = true
}

module "redis_iam_role" {
  source = "./modules/iam-role"

  role_name = "redis-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = merge(var.common_tags, { Name = "Redis IAM Role" })
  create_instance_profile = true
}

module "monitor_iam_role" {
  source = "./modules/iam-role"

  role_name = "monitor-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  tags = merge(var.common_tags, { Name = "Monitor IAM Role" })
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

# module "ssm_iam_role" {
#   source             = "./modules/iam-role"
#   role_name          = "ssm-ec2-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#   })
#   policy_arns = [
#     "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
#     "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
#     "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
#     "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
#     "arn:aws:iam::aws:policy/AutoScalingFullAccess",
#     "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   ]
#   tags = {
#     Environment = var.environment
#   }
#   create_instance_profile = true
# }

# module "mt_role" {
#   source             = "./modules/iam-role"
#   role_name          = "mt-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#   })
#   policy_arns = [
#     "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
#     "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
#   ]
#   inline_policies = [
#     {
#       Effect   = "Allow"
#       Action   = [
#         "ssmmessages:CreateDataChannel",
#         "ssmmessages:OpenDataChannel",
#         "ssmmessages:SendDataChannel",
#         "ssmmessages:ReceiveDataChannel"
#       ]
#       Resource = "*"
#     },
#     {
#       Effect   = "Allow"
#       Action   = [
#         "ec2:DescribeInstances",
#         "ec2:DescribeTags",
#         "ec2:DescribeRegions"
#       ]
#       Resource = "*"
#     },
#     {
#       Effect   = "Allow"
#       Action   = [
#         "ec2:DescribeNetworkInterfaces"
#       ]
#       Resource = "*"
#     }
#   ]
#   tags = {
#     Environment = var.environment
#   }
#   create_instance_profile = true
# }
