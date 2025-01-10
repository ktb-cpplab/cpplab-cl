data "aws_ssm_parameter" "db_password" {
  name            = var.db_password_parameter_name
  with_decryption = true
}

module "db_default" {
  source = "terraform-aws-modules/rds/aws"
  identifier                     = "cpplab-postgres-dev"
  instance_use_identifier_prefix = true

  create_db_option_group    = false
  create_db_parameter_group = false

  engine               = "postgres"
  engine_version       = "16.3"
  family               = "postgres16" # DB parameter group
  major_engine_version = "16.3"       # DB option group
  instance_class       = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp2"
  db_name  = "cpplab"
  username = "cpplab11"
  password = data.aws_ssm_parameter.db_password.value
  port     = 5432

  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.postgresql_security_group.security_group_id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0
}

module "update_rds_endpoint" {
  source          = "../modules/write-param"           
  parameter_name  = var.db_url_parameter_name         # Parameter Store의 경로
  new_value       = "jdbc:postgresql://${module.db_default.db_instance_endpoint}/cpplab"  # RDS 엔드포인트를 문자열로 연결
}

module "update_ai_db_url" {
  source          = "../modules/write-param"
  parameter_name  = var.ai_db_url_parameter_name      # Parameter Store의 경로
  new_value       = replace(module.db_default.db_instance_endpoint, ":5432", "")
}

module "postgresql_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "~> 5.0"

  name   = "postgresql-sg"
  vpc_id = module.vpc.vpc_id  # 사용할 VPC ID를 변수로 지정
}
