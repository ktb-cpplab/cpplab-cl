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
  
  # inline_policies = {
  #   ecs_deployment_policy = jsonencode({
  #     Version = "2012-10-17",
  #     Statement = [
  #       {
  #         Effect = "Allow",
  #         Action = [
  #           "ecs:RegisterTaskDefinition",
  #           "ecs:UpdateService"
  #         ],
  #         Resource = "*"
  #       }
  #     ]
  #   })
  # }
  
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
  source               = "./modules/ec2-instance"
  ami                  = var.jenkins_ami
  instance_type        = "t3a.medium"
  key_name             = var.key_name
  security_group_id    = module.jenkins_security_group.security_group_id
  subnet_id            = module.vpc.private_subnet_ids[0]
  instance_name        = "Jenkins"
  iam_instance_profile = module.ssm_iam_role.instance_profile_name
  root_volume_size     = 30
  tags                 = merge(var.tags, { Name = "Jenkins" })

}

resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = module.alb.jenkins-target-group-arn   # ALB 타겟 그룹의 ARN을 변수로 받음
  target_id        = module.jenkins_instance.instance_id
}

module "redis_instance" {
  source               = "./modules/ec2-instance"
  ami                  = var.redis_ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  security_group_id    = module.redis_security_group.security_group_id
  subnet_id            = module.vpc.private_subnet_ids[0]
  instance_name        = "Redis-ec2"
  iam_instance_profile = module.ssm_iam_role.instance_profile_name
  tags                 = merge(var.tags, { Name = "Redis" })
}

module "Monitor_instance" {
  source               = "./modules/ec2-instance"
  ami                  = var.mt_ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  security_group_id    = module.mt_security_group.security_group_id
  subnet_id            = module.vpc.public_subnet_ids[0]
  instance_name        = "Monitor-ec2"
  iam_instance_profile = module.ssm_iam_role.instance_profile_name
  tags                 = merge(var.tags, { Name = "Monitor" })
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
  instance_ami               = var.be_ami
  instance_type              = var.instance_type
  associate_public_ip_address = false
  security_group_ids         = [module.auto_scaling_be_security_group.security_group_id]
  subnet_ids                 = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
  key_name                   = var.key_name
  desired_capacity           = var.asg_desired_capacity
  max_size                   = var.asg_max_size
  min_size                   = var.asg_min_size
  target_group_arns          = [module.alb.be_target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "Backend"
  ecs_instance_type           = "be"
  //ecs_cluster_name           = module.ecs.ecs_cluster_id  # ECS 클러스터 이름 전달
}

module "auto_scaling_fe" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-fe"
  instance_ami               = var.instance_ami
  instance_type              = var.fe_instance_type
  associate_public_ip_address = true
  security_group_ids         = [module.auto_scaling_fe_security_group.security_group_id]
  subnet_ids                 = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1]]
  key_name                   = var.key_name
  desired_capacity           = var.asg_desired_capacity
  max_size                   = var.asg_max_size
  min_size                   = var.asg_min_size
  target_group_arns          = [module.alb.fe_target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "Frontend"
  ecs_instance_type           = "fe"
  //ecs_cluster_name           = module.ecs.ecs_cluster_id  # ECS 클러스터 이름 전달
}

module "auto_scaling_ai" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-ai"
  instance_ami               = var.instance_ami
  instance_type              = var.fe_instance_type
  associate_public_ip_address = false
  security_group_ids         = [module.auto_scaling_ai_security_group.security_group_id]
  subnet_ids                 = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
  key_name                   = var.key_name
  desired_capacity           = var.asg_desired_capacity
  max_size                   = var.asg_max_size
  min_size                   = var.asg_min_size
  target_group_arns          = [module.alb.ai_target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "AI"
  ecs_instance_type           = "ai"
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
  cluster_name               = aws_ecs_cluster.this.name
  task_family                = "ai-task-family"
  desired_count              = 1
  subnet_ids                 = module.vpc.private_subnet_ids
  security_group_ids         = [module.auto_scaling_ai_security_group.security_group_id]
  target_group_arn           = module.alb.ai_target_group_arn
  service_name               = "my-ai-service"
  execution_role_arn         = aws_iam_role.ecs_execution_role.arn

  containers = [
    {
      name      = "ai-container-1"
      image     = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/ai:recommend-latest"
      memory    = 512
      cpu       = 256
      essential = true
      portMappings = [{
        containerPort = 5000
        hostPort      = 5000
        protocol      = "tcp"
      }]
      secrets = [
        {
          name      = "DB_URL"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/db_url"
        },
        {
          name      = "MODEL_PATH"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/model/path"
        },
        {
          name      = "DB_NAME"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/db/name"
        },
        {
          name      = "DB_USER"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/spring/DB_USERNAME"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/spring/DB_PASSWORD"
        }
      ]
    },
    {
      name      = "ai-container-2"
      image     = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/ai:project-latest"
      memory    = 512
      cpu       = 256
      essential = true
      portMappings = [{
        containerPort = 5001
        hostPort      = 5001
        protocol      = "tcp"
      }]
      secrets = [
        {
          name      = "HUGGINGFACEHUB_API_TOKEN"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/HUGGINGFACEHUB_API_TOKEN"
        },
        {
          name      = "LANGCHAIN_API_KEY"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/LANGCHAIN_API_KEY"
        },
        {
          name      = "LANGCHAIN_ENDPOINT"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/LANGCHAIN_ENDPOINT"
        },
        {
          name      = "LANGCHAIN_PROJECT"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/LANGCHAIN_PROJECT"
        },
        {
          name      = "LANGCHAIN_TRACING_V2"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/LANGCHAIN_TRACING_V2"
        },
        {
          name      = "OPENAI_API_KEY"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/OPENAI_API_KEY"
        },
        {
          name      = "UPSTAGE_API_KEY"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/UPSTAGE_API_KEY"
        }
      ]
    }
  ]

  load_balancers = [
    {
      target_group_arn = module.alb.ai_target_group_arn
      container_name   = "ai-container-1"
      container_port   = 5000
    },
    {
      target_group_arn = module.alb.ai2_target_group_arn
      container_name   = "ai-container-2"
      container_port   = 5001
    }
  ]
}


# BE 파트
module "ecs_be" {
  source                     = "./modules/ecs"
  cluster_id                 = aws_ecs_cluster.this.id
  cluster_name               = aws_ecs_cluster.this.name
  task_family                = "be-task-family"
  desired_count              = 1
  subnet_ids                 = module.vpc.private_subnet_ids
  security_group_ids         = [module.auto_scaling_be_security_group.security_group_id]
  target_group_arn           = module.alb.be_target_group_arn
  service_name               = "my-be-service"
  execution_role_arn         = aws_iam_role.ecs_execution_role.arn

  containers = [
    {
      name      = "be-container"
      image     = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/be"
      memory    = 512
      cpu       = 256
      essential = true
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }]
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
  ]

  load_balancers = [
    {
      target_group_arn = module.alb.be_target_group_arn
      container_name   = "be-container"
      container_port   = 8080
    }
  ]
}
# FE 파트
module "ecs_fe" {
  source                     = "./modules/ecs"
  cluster_id                 = aws_ecs_cluster.this.id
  cluster_name               = aws_ecs_cluster.this.name
  task_family                = "fe-task-family"
  desired_count              = 1
  subnet_ids                 = module.vpc.public_subnet_ids
  security_group_ids         = [module.auto_scaling_fe_security_group.security_group_id]
  target_group_arn           = module.alb.fe_target_group_arn
  service_name               = "my-fe-service"
  execution_role_arn         = aws_iam_role.ecs_execution_role.arn


  containers = [
    {
      name      = "fe-container"
      image     = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/fe:latest"
      memory    = 256
      cpu       = 128
      essential = true
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }]
      secrets = []
    }
  ]

  load_balancers = [
    {
      target_group_arn = module.alb.fe_target_group_arn
      container_name   = "fe-container"
      container_port   = 3000
    }
  ]
}

########################################
#RDS

#postgres parameter db password
module "db_password" {
  source          = "./modules/read-param"
  parameter_name  = "/ecs/spring/DB_PASSWORD"  # Parameter Store의 경로
}
#rds db subnet group
# 프라이빗 서브넷 그룹 생성
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  description = "RDS subnet group for PostgreSQL database in private subnets"
  subnet_ids = module.vpc.private_subnet_ids  # VPC 모듈의 프라이빗 서브넷 ID 사용

  tags = {
    Name = "rds-subnet-group"
    Environment = "production"
  }
}

#postgres
module "rds_postgres" {
  source                     = "./modules/rds"
  
  # RDS 기본 설정
  allocated_storage          = 20                      # 기본 스토리지 (GB 단위)
  engine                     = "postgres"              # PostgreSQL 엔진 선택
  engine_version             = "16.3"                  # PostgreSQL 버전
  instance_class             = "db.t4g.micro"           # 인스턴스 유형

  # Database 정보
  db_name                    = "cpplab"            # 데이터베이스 이름
  username                   = "cpplab11"                 # 데이터베이스 사용자 이름
  password                   = module.db_password.value          # 데이터베이스 비밀번호
  parameter_group_name       = "default.postgres16"    # 파라미터 그룹 이름 (필요에 따라 설정)

  # 네트워크 및 보안 설정
  subnet_group               = aws_db_subnet_group.rds_subnet_group.name  # 서브넷 그룹 이름
  vpc_security_group_ids     = [module.postgres_security_group.security_group_id] # 백엔드 ASG 보안 그룹 ID (앞에서 설정한 것)

  # 백업 및 유지 관리
  backup_retention_period    = 0                       # 백업 보존 기간 (일 단위)
  # backup_window              = "07:00-09:00"           # 백업 윈도우 시간
  # maintenance_window         = "Mon:03:00-Mon:04:00"   # 유지 관리 윈도우 시간

  # 고가용성 및 성능 설정
  multi_az                   = false                   # 멀티 AZ 설정 여부
  storage_type               = "gp2"                   # 스토리지 유형 (기본: gp2)
  # max_allocated_storage      = 100                     # 최대 스토리지 크기 (자동 확장)

  # 태그 설정
  tags = {
    Name = "postgres-rds-instance"
    Environment = "production"
  }
}

# RDS 엔드포인트를 Parameter Store에 갱신
module "update_rds_endpoint" {
  source          = "./modules/write-param"           # 모듈 경로
  parameter_name  = "/ecs/spring/DB_URL"              # Parameter Store의 경로
  new_value       = "jdbc:postgresql://${module.rds_postgres.rds_endpoint}/postgres"  # RDS 엔드포인트 값을 문자열로 연결
}