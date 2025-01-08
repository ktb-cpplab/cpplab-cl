terraform {
  backend "s3" {
    bucket         = "cpplab-terraform-state-dev"
    key            = "terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "cpplab-terraform-lock-dev"
    encrypt        = true
  }
}