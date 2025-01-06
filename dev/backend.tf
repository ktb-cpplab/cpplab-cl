terraform {
  backend "s3" {
    bucket         = var.tfbackend_bucket
    key            = var.tfbackend_key
    region         = var.tfbackend_region
    dynamodb_table = var.tfbackend_dynamodb_table
    encrypt        = true
  }
}