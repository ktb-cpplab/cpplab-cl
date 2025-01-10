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
jenkins_ami = "ami-0a548c75d439d89ac"   # jenkins ami (수정완료 11.14)
be_ami = "ami-008826d9fbd497026"
redis_ami = "ami-01ce306e867ff466f"
mt_ami = "ami-01bb9eee7a203c8b7"        # 모니터링 ami (수정완료 11.18)

security_group_id = "sg-0123456789abcdef0"

# Auto Scaling 그룹
asg_desired_capacity = 1
asg_max_size         = 2
asg_min_size         = 1

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