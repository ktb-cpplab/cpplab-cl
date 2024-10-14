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

module "jenkins_instance" {
  source = "./modules/ec2-instance"

  ami              = var.instance_ami
  instance_type    = "t2.medium"
  key_name         = var.key_name
  security_group_id = aws_security_group.main.id
  subnet_id        = module.vpc.private_subnet_ids[0]
  instance_name     = "Jenkins"
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