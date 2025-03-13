module "multiple_ssm_parameters" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "1.1.2"

  for_each       = var.ssm_parameters
  name           = "/dev${each.key}"
  value          = each.value.value
  type           = each.value.type
  secure_type    = each.value.type == "SecureString" ? true : false
  description    = "Managed by Terraform"
}

# RDS 엔드포인트를 Parameter Store에 갱신

module "spring_DB_URL" {
  source  = "terraform-aws-modules/ssm-parameter/aws"

  name        = "/${var.environment}/ecs/spring/DB_URL"
  value       = "jdbc:postgresql://${module.rds_postgres.rds_endpoint}/postgres"
  secure_type = true
  depends_on = [ module.rds_postgres ]
}

module "ai_DB_URL" {
  source  = "terraform-aws-modules/ssm-parameter/aws"

  name        = "/${var.environment}/ecs/ai/db_url"
  value       = replace(module.rds_postgres.rds_endpoint, ":5432", "")
  secure_type = true
  depends_on = [ module.rds_postgres ]
}

module "CLOUD_DB" {
  source  = "terraform-aws-modules/ssm-parameter/aws"

  name        = "/${var.environment}/ecs/ai/CLOUD_DB"
  value       = "postgresql+psycopg://cpplab11:y1LLxJeCTKaUEvfHbHMi@${module.rds_postgres.rds_endpoint}/cpplab_rag"
  secure_type = true
  depends_on = [ module.rds_postgres ]
}