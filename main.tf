module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones  = var.availability_zones
  key_name            = var.key_name
  tags = merge(var.tags, { Environment = "dev" })

  nat_security_group_id = module.nat_security_group.security_group_id
}

module "ecs_cluster" {
  source       = "./modules/ecs/ecs_cluster"
  cluster_name = "cpplab-dev"
  tags = {
    Environment = "dev"
    Project     = "ECSProject"
  }
}


module "jenkins_instance" {
  source               = "./modules/ec2-instance"
  ami                  = var.jenkins_ami
  instance_type        = var.jenkins_instance_type
  key_name             = var.key_name
  security_group_id    = module.jenkins_security_group.security_group_id
  subnet_id            = module.vpc.private_subnet_ids[0]
  instance_name        = "Jenkins"
  iam_instance_profile = module.ssm_iam_role.instance_profile_name
  root_volume_size     = 30
  tags                 = merge(var.tags, { Name = "Jenkins" })
}

# Jenkins Target Group Attachment
resource "aws_lb_target_group_attachment" "jenkins_target" {
  target_group_arn = module.target_group["jenkins"].target_group_arn
  target_id        = module.jenkins_instance.instance_id
  port             = 8080
}

module "redis_instance" {
  source               = "./modules/ec2-instance"
  ami                  = var.redis_ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  security_group_id    = module.redis_security_group.security_group_id
  subnet_id            = module.vpc.private_subnet_ids[0]
  instance_name        = "Redis-ec2"
  iam_instance_profile = module.ssm_iam_role.instance_profile_name
  tags                 = merge(var.tags, { Name = "Redis" })
}

module "Monitor_instance" {
  source               = "./modules/ec2-instance"
  ami                  = var.mt_ami
  instance_type        = var.mt_instance_type
  key_name             = var.key_name
  security_group_id    = module.mt_security_group.security_group_id
  subnet_id            = module.vpc.public_subnet_ids[0]
  instance_name        = "Monitor-ec2"
  iam_instance_profile = module.ssm_iam_role.instance_profile_name
  tags                 = merge(var.tags, { Name = "Monitor" })
}