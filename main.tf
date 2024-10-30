module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones  = var.availability_zones
  key_name            = var.key_name
  tags = merge(var.tags, { Environment = "dev" })

  nat_security_group_id = module.nat_security_group.security_group_id
}


module "ssm_iam_role" {
  source            = "./modules/iam-role"
  role_name         = "ssm-ec2-role"
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
    Environment = "dev"
  }
}
resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecs-execution-role"
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
}

resource "aws_iam_policy" "parameter_access_policy" {
  name        = "ParameterAccessPolicy"
  description = "Allows ECS tasks to access AWS parameter Manager"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ssm:GetParameter",
        "ssm:GetParameters"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_parameter_access_policy" {
  policy_arn = aws_iam_policy.parameter_access_policy.arn
  role       = aws_iam_role.ecs_execution_role.name
}


module "jenkins_instance" {
  source = "./modules/ec2-instance"

  ami                  = var.jenkins_ami
  instance_type        = "t3a.medium"
  key_name             = var.key_name
  security_group_id    = module.jenkins_security_group.security_group_id
  subnet_id            = module.vpc.private_subnet_ids[0]
  instance_name        = "Jenkins"
  iam_instance_profile = module.ssm_iam_role.instance_profile_name
  tags                 = merge(var.tags, { Name = "Jenkins" })
  target_group_arn    = module.alb.jenkins-target-group-arn
}

module "alb" {
  source            = "./modules/alb"
  lb_name           = "alb"
  internal          = false
  security_group_ids = [module.alb_security_group.security_group_id]
  subnet_ids        = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
}

module "auto_scaling_be" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-be"
  instance_ami               = var.instance_ami
  instance_type              = var.be_instance_type
  associate_public_ip_address = false
  security_group_ids         = [module.auto_scaling_be_security_group.security_group_id]
  subnet_ids                 = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
  key_name                   = var.key_name
  desired_capacity           = 1
  max_size                   = 2
  min_size                   = 1
  target_group_arns          = [module.alb.be_target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "Backend"
  //ecs_cluster_name           = module.ecs.ecs_cluster_id  # ECS 클러스터 이름 전달
}

module "auto_scaling_fe" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-fe"
  instance_ami               = var.instance_ami
  instance_type              = var.instance_type
  associate_public_ip_address = true
  security_group_ids         = [module.auto_scaling_fe_security_group.security_group_id]
  subnet_ids                 = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1]]
  key_name                   = var.key_name
  desired_capacity           = 1
  max_size                   = 2
  min_size                   = 1
  target_group_arns          = [module.alb.fe_target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "Frontend"
  //ecs_cluster_name           = module.ecs.ecs_cluster_id  # ECS 클러스터 이름 전달
}

module "auto_scaling_ai" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-ai"
  instance_ami               = var.instance_ami
  instance_type              = var.instance_type
  associate_public_ip_address = false
  security_group_ids         = [module.auto_scaling_ai_security_group.security_group_id]
  subnet_ids                 = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
  key_name                   = var.key_name
  desired_capacity           = 1
  max_size                   = 2
  min_size                   = 1
  target_group_arns          = [module.alb.ai_target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "AI"
  //ecs_cluster_name           = module.ecs.ecs_cluster_id  # ECS 클러스터 이름 전달
}

resource "aws_ecs_cluster" "this" {
  name = "cpplab-ecs-cluster"  # 클러스터 이름
}

# ECS 모듈 호출
# AI 파트
module "ecs_ai" {
  source                     = "./modules/ecs"
  cluster_id                 = aws_ecs_cluster.this.id
  task_family                = "ai-task-family"
  container_name             = "ai-container"
  container_image            = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/ai:latest"
  memory                     = 512
  cpu                        = 256
  container_port             = 5000
  host_port                  = 5000
  desired_count              = 1
  subnet_ids                 = module.vpc.private_subnet_ids
  security_group_ids         = [module.auto_scaling_ai_security_group.security_group_id]
  target_group_arn           = module.alb.ai_target_group_arn
  service_name               = "my-ai-service"
  execution_role_arn         = aws_iam_role.ecs_execution_role.arn  # IAM 역할 ARN 전달
}
# BE 파트
module "ecs_be" {
  source                     = "./modules/ecs"
  cluster_id                 = aws_ecs_cluster.this.id
  task_family                = "be-task-family"
  container_name             = "be-container"
  container_image            = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/be"
  memory                     = 512
  cpu                        = 256
  container_port             = 8080
  host_port                  = 8080
  desired_count              = 1
  subnet_ids                 = module.vpc.private_subnet_ids
  security_group_ids         = [module.auto_scaling_be_security_group.security_group_id]
  target_group_arn           = module.alb.be_target_group_arn
  service_name               = "my-be-service"
  execution_role_arn         = aws_iam_role.ecs_execution_role.arn  # IAM 역할 ARN 전달
  # Parameter 전달
  secrets = [
    {
      name      = "DB_URL"
      valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/spring/DB_URL"
    },
    {
      name      = "DB_USERNAME"
      valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/spring/DB_USERNAME"
    },
    {
      name      = "DB_PASSWORD"
      valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/spring/DB_PASSWORD"
    },
    {
      name      = "JWT_SECRET"
      valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/spring/JWT_SECRET"
    },
    {
      name      = "KAKAO_CLIENT_SECRET"
      valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/spring/KAKAO_CLIENT_SECRET"
    },
    {
      name      = "NAVER_CLIENT_SECRET"
      valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/spring/NAVER_CLIENT_SECRET"
    }
  ]
}
# FE 파트
module "ecs_fe" {
  source                     = "./modules/ecs"
  cluster_id                 = aws_ecs_cluster.this.id
  task_family                = "fe-task-family"
  container_name             = "fe-container"
  container_image            = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/fe:latest"
  memory                     = 512
  cpu                        = 256
  container_port             = 3000
  host_port                  = 3000
  desired_count              = 1
  subnet_ids                 = module.vpc.public_subnet_ids
  security_group_ids         = [module.auto_scaling_fe_security_group.security_group_id]
  target_group_arn           = module.alb.fe_target_group_arn
  service_name               = "my-fe-service"
  execution_role_arn         = aws_iam_role.ecs_execution_role.arn  # IAM 역할 ARN 전달
}
