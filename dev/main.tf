module "vpc" {
  source = "../modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones  = var.availability_zones
  key_name            = var.key_name
  tags = merge(var.tags, { Environment = var.environment })

  nat_security_group_id = module.nat_security_group.security_group_id
}

module "ecs_cluster" {
  source       = "../modules/ecs/ecs_cluster"
  cluster_name = "cpplab-dev"
  tags = {
    Environment = var.environment
    Project     = "ECSProject"
  }
}


module "jenkins_instance" {
  source               = "../modules/ec2-instance"
  ami                  = var.jenkins_ami
  instance_type        = var.jenkins_instance_type
  key_name             = var.key_name
  security_group_id    = module.jenkins_security_group.security_group_id
  subnet_id            = module.vpc.private_subnet_ids[0]
  instance_name        = "Jenkins"
  iam_instance_profile = module.jenkins_iam_role.instance_profile_name 
  root_volume_size     = 30
  tags                 = merge(var.tags, { Name = "dev-Jenkins" })
}

# Jenkins Target Group Attachment
resource "aws_lb_target_group_attachment" "jenkins_target" {
  target_group_arn = module.target_group["jenkins"].target_group_arn
  target_id        = module.jenkins_instance.instance_id
  port             = 8080
}

module "redis_instance" {
  source               = "../modules/ec2-instance"
  ami                  = var.redis_ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  security_group_id    = module.redis_security_group.security_group_id
  subnet_id            = module.vpc.private_subnet_ids[0]
  instance_name        = "Redis-ec2"
  iam_instance_profile = module.redis_iam_role.instance_profile_name
  tags                 = merge(var.tags, { Name = "dev-Redis" })
}

module "Monitor_instance" {
  source               = "../modules/ec2-instance"
  ami                  = var.mt_ami
  instance_type        = var.mt_instance_type
  key_name             = var.key_name
  security_group_id    = module.mt_security_group.security_group_id
  subnet_id            = module.vpc.public_subnet_ids[0]
  instance_name        = "Monitor-ec2"
  iam_instance_profile = module.monitor_iam_role.instance_profile_name
  tags                 = merge(var.tags, { Name = "dev-Monitor" })
}

resource "aws_instance" "elk_instance" {
  ami                    = var.elk_ami  # ELK에 필요한 AMI ID
  instance_type          = var.elk_instance_type
  key_name               = var.key_name
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.elk_security_group.security_group_id]  # ELK 보안 그룹 연결
  associate_public_ip_address = true
  iam_instance_profile        = module.elk_iam_role.instance_profile_name

  tags = merge(var.common_tags, { Name = "dev-elk-instance" })
}