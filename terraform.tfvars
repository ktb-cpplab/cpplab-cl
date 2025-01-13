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