variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "lifecycle_policy" {
  description = "Lifecycle policy for ECR repository"
  type        = string
  default     = <<EOL
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Delete untagged images older than 30 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOL
}

variable "repository_policy" {
  description = "Repository policy JSON for the ECR repository"
  type        = string
  default     = <<EOL
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  ]
}
EOL
}
