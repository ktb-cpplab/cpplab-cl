module "acm" {
  source      = "../modules/acm"
  domain_name = "cpplab.store"
  environment = "dev"
}
