module "ecr" {
  source = "../modules/ecr"

  name = "cpplab-fe/dev"

  # Optional: Override default lifecycle policy
  lifecycle_policy = <<EOL
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 60 days",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["dev"],
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 60
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOL
}
