module "multiple_ssm_parameters" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "1.1.2"

  for_each       = var.ssm_parameters
  name           = each.key
  value          = each.value.value
  type           = each.value.type
  secure_type    = each.value.type == "SecureString" ? true : false
  description    = "Managed by Terraform"
}