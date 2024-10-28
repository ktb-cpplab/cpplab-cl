# security_groups.tf

# Jenkins 보안 그룹 모듈
module "jenkins_security_group" {
  source        = "./modules/security-group"
  name          = "jenkins-security-group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# ALB 보안 그룹 모듈
module "alb_security_group" {
  source        = "./modules/security-group"
  name          = "alb-security-group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# Auto Scaling BE 보안 그룹 모듈
module "auto_scaling_be_security_group" {
  source        = "./modules/security-group"
  name          = "auto-scaling-be-security-group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.alb_security_group.security_group_id]
    },
    {
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      security_groups = [module.alb_security_group.security_group_id]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# Auto Scaling FE 보안 그룹 모듈
module "auto_scaling_fe_security_group" {
  source        = "./modules/security-group"
  name          = "auto-scaling-fe-security-group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.alb_security_group.security_group_id]
    },
    {
      from_port       = 3000
      to_port         = 3000
      protocol        = "tcp"
      security_groups = [module.alb_security_group.security_group_id]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# Auto Scaling AI 보안 그룹 모듈
module "auto_scaling_ai_security_group" {
  source        = "./modules/security-group"
  name          = "auto_scaling_ai_security_group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.alb_security_group.security_group_id]
    },
    {
      from_port       = 5000
      to_port         = 5000
      protocol        = "tcp"
      security_groups = [module.alb_security_group.security_group_id]
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# NAT 인스턴스 보안 그룹 모듈
module "nat_security_group" {
  source = "./modules/security-group"
  name   = "nat-instance-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    # 인바운드 규칙 1: SSH 접근 (보안을 위해 특정 IP로 제한 가능)
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 허용
    },
    # 인바운드 규칙 2: HTTPS (VPC CIDR 범위에서)
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]  # VPC CIDR에서만 접근 허용
    },
    # 인바운드 규칙 3: HTTP (VPC CIDR 범위에서)
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    },
    # 인바운드 규칙 4: 모든 ICMP - IPv4 (VPC CIDR 범위에서)
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    }
  ]

  egress_rules = [
    # 모든 아웃바운드 트래픽 허용
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}