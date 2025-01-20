#RDS
#postgres parameter db password
# module "db_password" {
#   source          = "./modules/read-param"
#   parameter_name  = "/ecs/spring/DB_PASSWORD"  # Parameter Store의 경로
# }
#rds db subnet group
# 프라이빗 서브넷 그룹 생성
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  description = "RDS subnet group for PostgreSQL database in private subnets"
  subnet_ids = module.vpc.private_subnet_ids  # VPC 모듈의 프라이빗 서브넷 ID 사용

  tags = {
    Name = "rds-subnet-group"
    Environment = var.environment
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
  password                   = var.db_password      # 데이터베이스 비밀번호
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
    Environment = var.environment
  }
}

# RDS 엔드포인트를 Parameter Store에 갱신

module "spring_DB_URL" {
  source  = "terraform-aws-modules/ssm-parameter/aws"

  name        = "/${var.environment}/ecs/spring/DB_URL"
  value       = "jdbc:postgresql://${module.rds_postgres.rds_endpoint}/postgres"
  secure_type = true
}

module "ai_DB_URL" {
  source  = "terraform-aws-modules/ssm-parameter/aws"

  name        = "/${var.environment}/ecs/ai/db_url"
  value       = replace(module.rds_postgres.rds_endpoint, ":5432", "")
  secure_type = true
}

module "CLOUD_DB" {
  source  = "terraform-aws-modules/ssm-parameter/aws"

  name        = "/${var.environment}/ecs/ai/CLOUD_DB"
  value       = "postgresql+psycopg://cpplab11:y1LLxJeCTKaUEvfHbHMi@${module.rds_postgres.rds_endpoint}/cpplab_rag"
  secure_type = true
}

# module "update_rds_endpoint" {
#   source          = "./modules/write-param"           # 모듈 경로
#   parameter_name  = "/ecs/spring/DB_URL"              # Parameter Store의 경로
#   new_value       = "jdbc:postgresql://${module.rds_postgres.rds_endpoint}/postgres"  # RDS 엔드포인트 값을 문자열로 연결
# }

# module "update_ai_db_url" {
#   source          = "./modules/write-param"           # 모듈 경로
#   parameter_name  = "/ecs/ai/db_url"                  # Parameter Store의 경로
#   new_value       = replace(module.rds_postgres.rds_endpoint, ":5432", "")
# }