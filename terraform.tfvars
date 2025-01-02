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

###### Auto Scaling 그룹######
asg_desired_capacity = 1
asg_max_size         = 2
asg_min_size         = 1

tags = {
  Name        = "MyInstance"
  Environment = "dev"
  ManagedBy   = "terraform"
}

certificate_arn = "arn:aws:acm:ap-northeast-2:891612581533:certificate/a36ed071-ed0f-428c-b18f-0fa42f5f0dd4"

###### backend.tf ######
tfbackend_bucket         = "cpplab-terraform-state-dev"
tfbackend_key            = "terraform.tfstate"
tfbackend_region         = "ap-northeast-2"
tfbackend_dynamodb_table = "cpplab-terraform-lock-dev"

###### security_groups.tf ######
# CIDR blocks for ingress and egress
allowed_cidr_blocks = ["0.0.0.0/0"]  # Replace with specific IP ranges -> 일단 0.0.0.0/0으로 열어두겠음
allowed_egress_cidr_blocks = ["0.0.0.0/0"]

###### rds.tf ######
# 기본 설정
db_password_parameter_name = "/ecs/spring/DB_PASSWORD"
rds_subnet_group_name      = "rds-subnet-group"
rds_subnet_group_description = "RDS subnet group for PostgreSQL database in private subnets"
private_subnet_ids         = ["subnet-0123456789abcdef0", "subnet-0abcdef1234567890"]

# RDS 설정
allocated_storage          = 20
engine                     = "postgres"
engine_version             = "16.3"
instance_class             = "db.t4g.micro"
db_name                    = "cpplab"
db_username                = "cpplab11"
parameter_group_name       = "default.postgres16"
vpc_security_group_ids     = ["sg-0123456789abcdef0"]

# 백업 및 유지 관리
backup_retention_period    = 0
# backup_window              = "07:00-09:00"
# maintenance_window         = "Mon:03:00-Mon:04:00"

# 고가용성 및 성능
multi_az                   = false
storage_type               = "gp2"
# max_allocated_storage      = 100

# 태그
rds_instance_name          = "postgres-rds-instance"

# Parameter Store
db_url_parameter_name      = "/ecs/spring/DB_URL"
ai_db_url_parameter_name   = "/ecs/ai/db_url"


###### iam_role.tf ######

# SSM IAM Role
ssm_iam_role_name = "ssm-ec2-role"
ssm_assume_role_policy = {
  Version = "2012-10-17"
  Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
      Service = "ec2.amazonaws.com"
    }
  }]
}
ssm_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
  "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
  "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
  "arn:aws:iam::aws:policy/AutoScalingFullAccess",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
]

# ECS Execution Role
ecs_execution_role_name = "ecs_execution_role"
ecs_assume_role_policy = {
  Version = "2012-10-17"
  Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
      Service = "ecs-tasks.amazonaws.com"
    }
  }]
}
ecs_inline_policies = [
  {
    Effect   = "Allow"
    Action   = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    Resource = "*"
  }
]

# Monitoring Role (mt_role)
mt_role_name = "mt-role"
mt_assume_role_policy = {
  Version = "2012-10-17"
  Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
      Service = "ec2.amazonaws.com"
    }
  }]
}
mt_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
]
mt_inline_policies = [
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

# 공통 변수
environment = "dev"