region = "ap-northeast-2"

vpc_cidr = "192.170.0.0/16"
public_subnet_cidr = "192.170.1.0/24"
private_subnet_cidr = "192.170.2.0/24"
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]

key_name = "cpplab-keypair"

instance_type = "t2.micro"
mt_instance_type = "t3a.medium"
be_instance_type = "t3a.small"
ai_instance_type = "t3a.small"
fe_instance_type = "t3a.small"
nat_instance_type = "t2.micro"
jenkins_instance_type = "t3a.medium"

nat_ami = "ami-0e0ce674db551c1a5"
instance_ami = "ami-012880a6f6805d019"  # docker, node exporter, cAdvisor (수정완료 11.15)
jenkins_ami = "ami-0303f5b7e0cf543a0"   # jenkins ami (수정완료 11.14)
be_ami = "ami-008826d9fbd497026"
redis_ami = "ami-01ce306e867ff466f"
mt_ami = "ami-01bb9eee7a203c8b7"        # 모니터링 ami (수정완료 11.18)

security_group_id = "sg-0123456789abcdef0"

################################################################################
# ASG 설정
################################################################################
domain_name = "cpplab.store"


################################################################################
# ASG 설정
################################################################################
asg_desired_capacity = 1
asg_max_size         = 2
asg_min_size         = 1

launch_heartbeat_timeout = 30
terminate_heartbeat_timeout = 30

tags = {
  Name        = "MyInstance"
  Environment = "dev"
  ManagedBy   = "terraform"
}

certificate_arn = "arn:aws:acm:ap-northeast-2:891612581533:certificate/a36ed071-ed0f-428c-b18f-0fa42f5f0dd4"

################################################################################
# ALB 설정
################################################################################

alb_tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
}
target_group_tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
}
alb_jenkins_name = "jenkins-alb"
alb_fe_name = "alb-fe"
alb_main_name = "alb-main"
tg_jenkins_name = "jenkins-target-group"
tg_fe_name = "frontend-target-group"
tg_be_name = "backend-target-group"
tg_ai1_name = "pickle-tg"
tg_ai2_name = "progen-tg"
be_path_patterns = ["/api/*", "/oauth2/*", "/login/*"]
ai1_path_patterns = ["/ai/recommend","/ai/updatechain","/ai/delsession","/ai/test/asyncgenproject","/ai/test/syncgenproject"]
ai2_path_patterns = ["/ai/genproject", "/ai/regenproject"]

################################################################################
#  parameter store
################################################################################

ssm_parameters = {
  "/ecs/ai/CLOUD_REDIS" = {
    value = "192.170.2.24"
    type  = "String"
  }
  "/ecs/ai/HUGGINGFACEHUB_API_TOKEN" = {
    value = "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"
    type  = "SecureString"
  }
  "/ecs/ai/LANGCHAIN_API_KEY" = {
    value = "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"
    type  = "SecureString"
  }
  "/ecs/ai/LANGCHAIN_PROJECT" = {
    value = "LangChain_Note"
    type  = "SecureString"
  }
  "/ecs/ai/LANGCHAIN_ENDPOINT" = {
    value = "https://api.smith.langchain.com"
    type  = "SecureString"
  }
  "/ecs/ai/LANGCHAIN_TRACING_V2" = {
    value = "True"
    type  = "SecureString"
  }
  "/ecs/ai/OPENAI_API_KEY" = {
    value = "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"
    type  = "SecureString"
  }
  "/ecs/ai/UPSTAGE_API_KEY" = {
    value = "up_l6bY8Yh6Pnn49ROs3GTA6PGGnKY6v"
    type  = "SecureString"
  }
  "/ecs/ai/db_port" = {
    value = "5432"
    type  = "SecureString"
  }
  "/ecs/ai/mecab/path" = {
    value = "/app/mecab/mecab-ko-dic-2.1.1-20180720"
    type  = "SecureString"
  }
  "/ecs/ai/model/path" = {
    value = "/app/models/ko-sroberta-multitask/models--jhgan--ko-sroberta-multitask/blobs"
    type  = "SecureString"
  }
  "/ecs/db/name" = {
    value = "postgres"
    type  = "SecureString"
  }
  "/ecs/spring/DB_PASSWORD" = {
    value = "y1LLxJeCTKaUEvfHbHMi"
    type  = "SecureString"
  }
  "/ecs/spring/DB_USERNAME" = {
    value = "cpplab11"
    type  = "SecureString"
  }
  "/ecs/spring/JWT_SECRET" = {
    value = "vmfhaltmskdlstkfkdgodyroqkfwkdbalroqkfwkdballywaaaaaaaaaaaaabbbbb"
    type  = "SecureString"
  }
  "/ecs/spring/KAKAO_CLIENT_SECRET" = {
    value = "joxB6tCG2K7ijC6ZVm7edJf50c9ZRWsI"
    type  = "SecureString"
  }
  "/ecs/spring/NAVER_CLIENT_SECRET" = {
    value = "r6K_d4HBNa"
    type  = "SecureString"
  }
}

################################################################################
#  RDS.tf
################################################################################

db_password = "y1LLxJeCTKaUEvfHbHMi"

################################################################################
#  ECS.tf
################################################################################
ecs_frontend_config = {
  task_family_name   = "dev-fe-task-family"
  service_name       = "dev-fe-service"
  desired_count      = 1
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
  capacity_provider = {
    name = "fe-capacity-provider"
    managed_termination_protection = "DISABLED"
    maximum_scaling_step_size = 1
    minimum_scaling_step_size = 1
    scaling_status = "value"
    target_capacity = 100
  }
}

ecs_backend_config = {
  task_family_name   = "dev-be-task-family"
  service_name       = "dev-be-service"
  desired_count      = 1
  containers = [
    {
      name      = "be-container"
      image     = "891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/cpplab/be:latest"
      memory    = 1536
      cpu       = 1536
      essential = true
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
        protocol      = "tcp"
      }]
      secrets = [
        { name = "DB_URL",
          valueFrom = "arn:aws:ssm:ap-northeast-2:123456789012:parameter/ecs/dev/DB_URL" 
        },
        { name = "DB_USERNAME"
          valueFrom = "arn:aws:ssm:ap-northeast-2:123456789012:parameter/ecs/dev/DB_USERNAME" 
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
  capacity_provider = {
    name = "be-capacity-provider"
    managed_termination_protection = "DISABLED"
    maximum_scaling_step_size = 1
    minimum_scaling_step_size = 1
    scaling_status = "value"
    target_capacity = 100
  }
}

ecs_ai_config = {
  task_family_name   = "dev-ai-task-family"
  service_name       = "dev-ai-service"
  desired_count      = 1
  containers = [
    {
      name      = "ai-container-peter"
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
      name      = "ai-container-simon"
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
  capacity_provider = {
    name = "ai-capacity-provider"
    managed_termination_protection = "DISABLED"
    maximum_scaling_step_size = 1
    minimum_scaling_step_size = 1
    scaling_status = "value"
    target_capacity = 100
  }
}

capacity_providers = {
  ai = {
    name                           = "ai-capacity-provider"
    managed_termination_protection = "DISABLED"
    maximum_scaling_step_size      = 1
    minimum_scaling_step_size      = 1
    scaling_status                 = "ENABLED"
    target_capacity                = 100
  }
  be = {
    name                           = "be-capacity-provider"
    managed_termination_protection = "DISABLED"
    maximum_scaling_step_size      = 1
    minimum_scaling_step_size      = 1
    scaling_status                 = "ENABLED"
    target_capacity                = 100
  }
  fe = {
    name                           = "fe-capacity-provider"
    managed_termination_protection = "DISABLED"
    maximum_scaling_step_size      = 1
    minimum_scaling_step_size      = 1
    scaling_status                 = "ENABLED"
    target_capacity                = 100
  }
}
