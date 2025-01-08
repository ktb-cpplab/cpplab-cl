module "ecr_frontend" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.frontend_repository_name

  repository_read_write_access_arns = var.repository_read_write_access_arns
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = var.tag_status
          tagPrefixList = var.tag_prefix_list
          countType     = var.count_type
          countNumber   = var.count_number
        },
        action = {
          type = var.action_type
        }
      }
    ]
  })

  tags = var.frontend_tags
}

module "ecr_backend" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.backend_repository_name

  repository_read_write_access_arns = var.repository_read_write_access_arns
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = var.tag_status
          tagPrefixList = var.tag_prefix_list
          countType     = var.count_type
          countNumber   = var.count_number
        },
        action = {
          type = var.action_type
        }
      }
    ]
  })

  tags = var.backend_tags
}