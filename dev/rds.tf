# RDS
# postgres parameter db password
module "db_password" {
  source          = "./modules/read-param"
  parameter_name  = var.db_password_parameter_name  # Parameter Store의 경로 (변수화)
}

# rds db subnet group
# 프라이빗 서브넷 그룹 생성
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = var.rds_subnet_group_name  # 이름을 변수화
  description = var.rds_subnet_group_description  # 설명을 변수화
  subnet_ids  = var.private_subnet_ids  # 프라이빗 서브넷 ID를 변수화

  tags = {
    Name        = var.rds_subnet_group_name
    Environment = var.environment  # 환경 정보 변수화
  }
}

# postgres
module "rds_postgres" {
  source                     = "./modules/rds"
  
  # RDS 기본 설정
  allocated_storage          = var.allocated_storage          # 기본 스토리지 (GB 단위)
  engine                     = var.engine                     # PostgreSQL 엔진
  engine_version             = var.engine_version             # PostgreSQL 버전
  instance_class             = var.instance_class             # 인스턴스 유형

  # Database 정보
  db_name                    = var.db_name                    # 데이터베이스 이름
  username                   = var.db_username                # 데이터베이스 사용자 이름
  password                   = module.db_password.value       # 데이터베이스 비밀번호
  parameter_group_name       = var.parameter_group_name       # 파라미터 그룹 이름

  # 네트워크 및 보안 설정
  subnet_group               = aws_db_subnet_group.rds_subnet_group.name  # 서브넷 그룹 이름
  vpc_security_group_ids     = var.vpc_security_group_ids      # 보안 그룹 ID를 변수화

  # 백업 및 유지 관리
  backup_retention_period    = var.backup_retention_period    # 백업 보존 기간
  # backup_window              = var.backup_window              # 백업 윈도우 시간
  # maintenance_window         = var.maintenance_window         # 유지 관리 윈도우 시간

  # 고가용성 및 성능 설정
  multi_az                   = var.multi_az                   # 멀티 AZ 설정 여부
  storage_type               = var.storage_type               # 스토리지 유형
  # max_allocated_storage      = var.max_allocated_storage      # 최대 스토리지 크기

  # 태그 설정
  tags = {
    Name        = var.rds_instance_name
    Environment = var.environment
  }
}

# RDS 엔드포인트를 Parameter Store에 갱신
module "update_rds_endpoint" {
  source          = "./modules/write-param"           
  parameter_name  = var.db_url_parameter_name         # Parameter Store의 경로
  new_value       = "jdbc:postgresql://${module.rds_postgres.rds_endpoint}/${var.db_name}"  # RDS 엔드포인트를 문자열로 연결
}

module "update_ai_db_url" {
  source          = "./modules/write-param"
  parameter_name  = var.ai_db_url_parameter_name      # Parameter Store의 경로
  new_value       = replace(module.rds_postgres.rds_endpoint, ":5432", "")
}
