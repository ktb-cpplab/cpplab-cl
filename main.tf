module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones = var.availability_zones
  key_name           = var.key_name
  tags = merge(var.tags, { Environment = "dev" })
}

resource "aws_security_group" "main" {
  name        = "main-security-group"
  description = "Main security group for instances"
  vpc_id      = module.vpc.vpc_id  # VPC ID를 VPC 모듈로부터 받아옴

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH 접근 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "main-security-group" })
}

module "ssm_iam_role" {
  source            = "./modules/iam-role"
  role_name         = "ssm-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  tags = {
    Environment = "dev"
  }
}

module "jenkins_instance" {
  source = "./modules/ec2-instance"

  ami              = var.instance_ami
  instance_type    = "t3a.medium"
  key_name         = var.key_name
  security_group_id = aws_security_group.main.id
  subnet_id        = module.vpc.private_subnet_ids[0]
  instance_name     = "Jenkins"
  iam_instance_profile = module.ssm_iam_role.instance_profile_name
  tags             = merge(var.tags, { Name = "Jenkins" })
}

module "backend_instance" {
  source = "./modules/ec2-instance"

  ami              = var.instance_ami
  instance_type    = var.instance_type
  key_name         = var.key_name
  security_group_id = aws_security_group.main.id
  subnet_id        = module.vpc.private_subnet_ids[0]
  instance_name     = "Backend"
  iam_instance_profile = module.ssm_iam_role.instance_profile_name
  tags             = merge(var.tags, { Name = "Backend" })
}

module "frontend_instance" {
  source = "./modules/ec2-instance"

  ami              = var.instance_ami
  instance_type    = var.instance_type
  key_name         = var.key_name
  security_group_id = aws_security_group.main.id
  subnet_id        = module.vpc.public_subnet_ids[0]
  instance_name     = "Frontend"
  tags             = merge(var.tags, { Name = "Frontend" })
}

resource "aws_eip" "frontend_eip" {
  vpc      = true
  instance = module.frontend_instance.id  # 프론트엔드 인스턴스에 연결
  tags = {
    Name = "Frontend EIP"
  }
}

module "alb" {
  source            = "./modules/alb"
  lb_name           = "app-lb"
  internal          = false
  security_group_ids = [aws_security_group.main.id]
  subnet_ids        = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
}

module "auto_scaling_be" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-be"
  instance_ami               = var.instance_ami
  instance_type              = var.instance_type
  associate_public_ip_address = false
  security_group_ids         = [aws_security_group.main.id]
  subnet_ids                 = module.vpc.private_subnet_ids
  key_name                   = var.key_name
  desired_capacity           = 1
  max_size                   = 2
  min_size                   = 1
  target_group_arns          = [module.alb.be_target_group_arn]
  tag_name                   = "be-instance"
}

module "auto_scaling_fe" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-"
  instance_ami               = var.instance_ami
  instance_type              = var.instance_type
  associate_public_ip_address = true
  security_group_ids         = [aws_security_group.main.id]
  subnet_ids                 = module.vpc.public_subnet_ids
  key_name                   = var.key_name
  desired_capacity           = 1
  max_size                   = 2
  min_size                   = 1
  target_group_arns          = [module.alb.fe_target_group_arn]
  tag_name                   = "fe-instance"
}