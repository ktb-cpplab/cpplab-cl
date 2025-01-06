resource "aws_ecs_cluster" "this" {
  name = "cpplab-ecs-cluster"  # 클러스터 이름
}

module "ai_capacity_provider" {
  source                        = "./modules/ecs/capacity_provider"
  name                          = "ai-capacity-provider"
  auto_scaling_group_arn        = module.auto_scaling_ai.asg_arn
  managed_termination_protection = "DISABLED"
  maximum_scaling_step_size     = 1
  minimum_scaling_step_size     = 1
  scaling_status                = "ENABLED"
  target_capacity               = 100
}

module "be_capacity_provider" {
  source                        = "./modules/ecs/capacity_provider"
  name                          = "be-capacity-provider"
  auto_scaling_group_arn        = module.auto_scaling_be.asg_arn
  managed_termination_protection = "DISABLED"
  maximum_scaling_step_size     = 1
  minimum_scaling_step_size     = 1
  scaling_status                = "ENABLED"
  target_capacity               = 100
}

module "fe_capacity_provider" {
  source                        = "./modules/ecs/capacity_provider"
  name                          = "fe-capacity-provider"
  auto_scaling_group_arn        = module.auto_scaling_fe.asg_arn
  managed_termination_protection = "DISABLED"
  maximum_scaling_step_size     = 1
  minimum_scaling_step_size     = 1
  scaling_status                = "ENABLED"
  target_capacity               = 100
}


# 생성된 Capacity Provider들을 ECS 클러스터에 연결
resource "aws_ecs_cluster_capacity_providers" "cluster_providers" {
  cluster_name       = aws_ecs_cluster.this.name  # ECS 클러스터 이름
  capacity_providers = [
    module.ai_capacity_provider.name,
    module.be_capacity_provider.name,
    module.fe_capacity_provider.name
  ]
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
  target_group_arn           = module.tg_ai1.target_group_arn
  service_name               = "my-ai-service"
  execution_role_arn         = module.ecs_execution_role.iam_role_arn
  part_capacity_provider     = module.ai_capacity_provider.name  # AI 서비스의 Capacity Provider

  containers = [
    {
      name      = "ai-container-1"
      image     = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/ai:recommend-latest"
      memory    = 1024
      cpu       = 1024
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
        },
        {
          name      = "DB_PORT"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/db_port"
        },
        {
          name      = "MECAB_PATH"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/mecab/path"
        }
      ]
    },
    {
      name      = "ai-container-2"
      image     = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/ai:project-latest"
      memory    = 512
      cpu       = 512
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
        },
        {
          name      = "CLOUD_DB"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/CLOUD_DB"
        },
        {
          name      = "CLOUD_REDIS"
          valueFrom = "arn:aws:ssm:ap-northeast-2:891612581533:parameter/ecs/ai/CLOUD_REDIS"
        }
      ]
    }
  ]

  load_balancers = [
    {
      target_group_arn = module.tg_ai1.target_group_arn
      container_name   = "ai-container-1"
      container_port   = 5000
    },
    {
      target_group_arn = module.tg_ai2.target_group_arn
      container_name   = "ai-container-2"
      container_port   = 5001
    }
  ]

  depends_on = [ module.ecs_execution_role ]
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
  target_group_arn           = module.tg_be.target_group_arn
  service_name               = "my-be-service"
  execution_role_arn         = module.ecs_execution_role.iam_role_arn
  part_capacity_provider     = module.be_capacity_provider.name  # BE 서비스의 Capacity Provider

  containers = [
    {
      name      = "be-container"
      image     = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/be"
      memory    = 1536
      cpu       = 1536
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
      target_group_arn = module.tg_be.target_group_arn
      container_name   = "be-container"
      container_port   = 8080
    }
  ]
  depends_on = [ module.ecs_execution_role ]
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
  target_group_arn           = module.tg_fe.target_group_arn
  service_name               = "my-fe-service"
  execution_role_arn         = module.ecs_execution_role.iam_role_arn
  part_capacity_provider     = module.fe_capacity_provider.name  # FE 서비스의 Capacity Provider

  containers = [
    {
      name      = "fe-container"
      image     = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/fe:latest"
      memory    = 1024
      cpu       = 1024
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
      target_group_arn = module.tg_fe.target_group_arn
      container_name   = "fe-container"
      container_port   = 3000
    }
  ]
  depends_on = [ module.ecs_execution_role ]
}