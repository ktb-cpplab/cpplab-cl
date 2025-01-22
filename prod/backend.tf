terraform {
  backend "s3" {
    bucket         = "cpplab-terraform-state-prod"
    key            = "terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "cpplab-terraform-lock-prod"
    encrypt        = true
  }
}