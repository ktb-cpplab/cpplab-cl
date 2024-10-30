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

module "ecs_execution_role"{
  source            = "./modules/iam-role"
  role_name         = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    aws_iam_policy.secrets_access.arn
  ]
}

resource "aws_iam_policy" "secrets_access" {
  name        = "SecretsManagerAccess"
  description = "Policy to allow ECS tasks to access Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "arn:aws:secretsmanager:ap-northeast-2:891612581533:secret:ECS/Spring/Properties-sabTdr"
      }
    ]
  })
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
  instance_type              = var.instance_type
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
  cluster_id                 = aws_ecs_cluster.this.id  # 클러스터 ID 전달
  task_family                = "ai-task-family"           # AI 태스크 정의 이름
  container_name             = "ai-container"             # AI 컨테이너 이름
  container_image            = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/ai:latest"   # AI Docker 이미지
  memory                     = 512                         # 메모리
  cpu                        = 256                         # CPU 유닛
  container_port             = 5000                        # AI 서비스에 대한 컨테이너 포트
  host_port                  = 5000                        # 호스트 포트
  desired_count              = 1                           # AI 태스크의 원하는 개수
  subnet_ids                 = module.vpc.private_subnet_ids  # 프라이빗 서브넷 ID
  security_group_ids         = [module.auto_scaling_ai_security_group.security_group_id]  # 보안 그룹 ID
  target_group_arn           = module.alb.ai_target_group_arn  # ALB 타겟 그룹 ARN
  service_name               = "my-ai-service"            # AI 서비스 이름
  execution_role_arn = module.ecs_execution_role.arn
}

# BE 파트
module "ecs_be" {
  source                     = "./modules/ecs"
  cluster_id                 = aws_ecs_cluster.this.id  # 클러스터 ID 전달
  task_family                = "be-task-family"           # BE 태스크 정의 이름
  container_name             = "be-container"             # BE 컨테이너 이름
  container_image            = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/be"   # BE Docker 이미지
  memory                     = 512                         # 메모리
  cpu                        = 256                         # CPU 유닛
  container_port             = 8080                        # BE 서비스에 대한 컨테이너 포트
  host_port                  = 8080                        # 호스트 포트
  desired_count              = 1                           # BE 태스크의 원하는 개수
  subnet_ids                 = module.vpc.private_subnet_ids  # 프라이빗 서브넷 ID
  security_group_ids         = [module.auto_scaling_be_security_group.security_group_id]  # 보안 그룹 ID
  target_group_arn           = module.alb.be_target_group_arn  # ALB 타겟 그룹 ARN
  service_name               = "my-be-service"            # BE 서비스 이름
  execution_role_arn = module.ecs_execution_role.arn
  # Secrets Manager 시크릿 전달
  secrets = [
    {
      name      = "DB_URL"
      valueFrom = "arn:aws:secretsmanager:ap-northeast-2:891612581533:secret:ECS/Spring/Properties-sabTdr:DB_URL"
    },
    {
      name      = "DB_USERNAME"
      valueFrom = "arn:aws:secretsmanager:ap-northeast-2:891612581533:secret:ECS/Spring/Properties-sabTdr:DB_USERNAME"
    },
    {
      name      = "DB_PASSWORD"
      valueFrom = "arn:aws:secretsmanager:ap-northeast-2:891612581533:secret:ECS/Spring/Properties-sabTdr:DB_PASSWORD"
    },
    {
      name      = "JWT_SECRET"
      valueFrom = "arn:aws:secretsmanager:ap-northeast-2:891612581533:secret:ECS/Spring/Properties-sabTdr:JWT_SECRET"
    },
    {
      name      = "KAKAO_CLIENT_ID"
      valueFrom = "arn:aws:secretsmanager:ap-northeast-2:891612581533:secret:ECS/Spring/Properties-sabTdr:KAKAO_CLIENT_ID"
    },
    {
      name      = "KAKAO_CLIENT_SECRET"
      valueFrom = "arn:aws:secretsmanager:ap-northeast-2:891612581533:secret:ECS/Spring/Properties-sabTdr:KAKAO_CLIENT_SECRET"
    },
    {
      name      = "NAVER_CLIENT_ID"
      valueFrom = "arn:aws:secretsmanager:ap-northeast-2:891612581533:secret:ECS/Spring/Properties-sabTdr:NAVER_CLIENT_ID"
    },
    {
      name      = "NAVER_CLIENT_SECRET"
      valueFrom = "arn:aws:secretsmanager:ap-northeast-2:891612581533:secret:ECS/Spring/Properties-sabTdr:NAVER_CLIENT_SECRET"
    }
  ]
}

# FE 파트
module "ecs_fe" {
  source                     = "./modules/ecs"
  cluster_id                 = aws_ecs_cluster.this.id  # 클러스터 ID 전달
  task_family                = "fe-task-family"           # FE 태스크 정의 이름
  container_name             = "fe-container"             # FE 컨테이너 이름
  container_image            = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/fe:latest"   # FE Docker 이미지
  memory                     = 512                         # 메모리
  cpu                        = 256                         # CPU 유닛
  container_port             = 3000                          # FE 서비스에 대한 컨테이너 포트
  host_port                  = 3000                          # 호스트 포트
  desired_count              = 1                           # FE 태스크의 원하는 개수
  subnet_ids                 = module.vpc.public_subnet_ids   # 퍼블릭 서브넷 ID
  security_group_ids         = [module.auto_scaling_fe_security_group.security_group_id]  # 보안 그룹 ID
  target_group_arn           = module.alb.fe_target_group_arn  # ALB 타겟 그룹 ARN
  service_name               = "my-fe-service"             # FE 서비스의 이름입니다.
  execution_role_arn = module.ecs_execution_role.arn
}
