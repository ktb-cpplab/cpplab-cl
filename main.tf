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

module "jenkins_instance" {
  source               = "./modules/ec2-instance"
  ami                  = var.jenkins_ami
  instance_type        = "t3a.large"
  key_name             = var.key_name
  security_group_id    = module.jenkins_security_group.security_group_id
  subnet_id            = module.vpc.private_subnet_ids[0]
  instance_name        = "Jenkins"
  iam_instance_profile = module.ssm_iam_role.instance_profile_name
  root_volume_size     = 30
  tags                 = merge(var.tags, { Name = "Jenkins" })
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
  target_group_arns          = [module.tg_be.target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "Backend"
  ecs_instance_type           = "be"

  depends_on = [module.ssm_iam_role]
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
  target_group_arns          = [module.tg_fe.target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "Frontend"
  ecs_instance_type           = "fe"

  depends_on = [module.ssm_iam_role]
}

module "auto_scaling_ai" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-ai"
  instance_ami               = var.instance_ami
  instance_type              = var.ai_instance_type
  associate_public_ip_address = false
  security_group_ids         = [module.auto_scaling_ai_security_group.security_group_id]
  subnet_ids                 = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
  key_name                   = var.key_name
  desired_capacity           = var.asg_desired_capacity
  max_size                   = var.asg_max_size
  min_size                   = var.asg_min_size
  target_group_arns          = [module.tg_ai1.target_group_arn, module.tg_ai2.target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "AI"
  ecs_instance_type           = "ai"

  depends_on = [module.ssm_iam_role]
}

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