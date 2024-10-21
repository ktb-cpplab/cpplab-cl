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

  ami                  = var.jenkins_ami
  instance_type        = "t3a.medium"
  key_name             = var.key_name
  security_group_id    = module.jenkins_security_group.security_group_id
  subnet_id            = module.vpc.private_subnet_ids[0]
  instance_name        = "Jenkins"
  iam_instance_profile = module.ssm_iam_role.instance_profile_name
  tags                 = merge(var.tags, { Name = "Jenkins" })
}

# module "backend_instance" {
#   source = "./modules/ec2-instance"

#   ami              = var.instance_ami
#   instance_type    = var.instance_type
#   key_name         = var.key_name
#   security_group_id = aws_security_group.main.id
#   subnet_id        = module.vpc.private_subnet_ids[0]
#   instance_name     = "Backend"
#   iam_instance_profile = module.ssm_iam_role.instance_profile_name
#   tags             = merge(var.tags, { Name = "Backend" })
# }

# module "frontend_instance" {
#   source = "./modules/ec2-instance"

#   ami              = var.instance_ami
#   instance_type    = var.instance_type
#   key_name         = var.key_name
#   security_group_id = aws_security_group.main.id
#   subnet_id        = module.vpc.public_subnet_ids[0]
#   instance_name     = "Frontend"
#   tags             = merge(var.tags, { Name = "Frontend" })
# }

# resource "aws_eip" "frontend_eip" {
#   vpc      = true
#   instance = module.frontend_instance.id  # 프론트엔드 인스턴스에 연결
#   tags = {
#     Name = "Frontend EIP"
#   }
# }

module "alb" {
  source            = "./modules/alb"
  lb_name           = "app-lb"
  internal          = false
  security_group_ids = [module.alb_security_group.security_group_id]
  subnet_ids        = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
}

module "auto_scaling_be" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-be"
  instance_ami               = var.instance_ami
  instance_type              = var.instance_type
  associate_public_ip_address = false
  security_group_ids         = [module.auto_scaling_be_security_group.security_group_id]
  subnet_ids                 = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
  key_name                   = var.key_name
  desired_capacity           = 1
  max_size                   = 2
  min_size                   = 1
  target_group_arns          = [module.alb.be_target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "Backend"
  //ecs_cluster_name           = module.ecs.ecs_cluster_id  # ECS 클러스터 이름 전달
}

module "auto_scaling_fe" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-"
  instance_ami               = var.instance_ami
  instance_type              = var.instance_type
  associate_public_ip_address = true
  security_group_ids         = [module.auto_scaling_fe_security_group.security_group_id]
  subnet_ids                 = [module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1]]
  key_name                   = var.key_name
  desired_capacity           = 1
  max_size                   = 2
  min_size                   = 1
  target_group_arns          = [module.alb.fe_target_group_arn]
  tag_name                   = "Frontend"
  //ecs_cluster_name           = module.ecs.ecs_cluster_id  # ECS 클러스터 이름 전달
}

module "auto_scaling_ai" {
  source                     = "./modules/auto-scaling"
  name_prefix                = "launch-template-"
  instance_ami               = var.instance_ami
  instance_type              = var.instance_type
  associate_public_ip_address = false
  security_group_ids         = [module.auto_scaling_ai_security_group.security_group_id]
  subnet_ids                 = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
  key_name                   = var.key_name
  desired_capacity           = 1
  max_size                   = 2
  min_size                   = 1
  target_group_arns          = [module.alb.ai_target_group_arn]
  iam_instance_profile       = module.ssm_iam_role.instance_profile_name
  tag_name                   = "AI"
  //ecs_cluster_name           = module.ecs.ecs_cluster_id  # ECS 클러스터 이름 전달
}

# # ECS 모듈 호출
# module "ecs" {
#   source                     = "./modules/ecs"

#   name_prefix                = "cpplab-ecs"  # ECS 리소스 명명 시 사용할 접두사
#   container_image            = var.container_image  # 사용할 도커 이미지
#   container_cpu              = var.container_cpu  # 컨테이너에 할당할 CPU 유닛
#   container_memory           = var.container_memory  # 컨테이너에 할당할 메모리
#   container_port             = var.container_port  # 컨테이너에서 사용할 포트
#   host_port                  = var.host_port  # 호스트에서 매핑할 포트
#   desired_count              = var.desired_count  # 원하는 실행 중인 태스크 수
#   subnet_ids                 = module.vpc.private_subnet_ids  # ECS가 배포될 서브넷 ID
#   security_group_ids         = [module.auto_scaling_be_security_group.security_group_id]  # ECS 서비스의 보안 그룹 ID
#   target_group_arns          = [module.alb.be_target_group_arn]  # EC2 서비스와 관련된 타겟 그룹 ARN
# }