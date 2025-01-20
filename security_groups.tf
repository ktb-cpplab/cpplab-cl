# security_groups.tf

# # ELK 보안 그룹 모듈
# module "elk_security_group" {
#   source        = "./modules/security-group"
#   name          = "elk-security-group"
#   vpc_id        = module.vpc.vpc_id

#   ingress_rules = [
#     # Kibana (포트 5601): 관리자 IP만 허용
#     {
#       from_port   = 5601
#       to_port     = 5601
#       protocol    = "tcp"
#       cidr_blocks = var.admin_cidr_blocks  # 관리자의 CIDR 블록
#     },
#     # Elasticsearch (포트 9200~9300): Kibana 및 내부 통신
#     {
#       from_port   = 9200
#       to_port     = 9300
#       protocol    = "tcp"
#       security_groups = [
#         module.elk_security_group.security_group_id  # 자기 자신과의 통신 (클러스터 간)
#       ]
#     }
#   ]

#   egress_rules = [
#     # S3와 HTTPS 통신 (포트 443)
#     {
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]  # AWS S3와 통신
#     },
#     # 모든 아웃바운드 트래픽 허용 (옵션)
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   ]
# }

# Monitor 보안 그룹 모듈
module "mt_security_group" {
  source        = "./modules/security-group"
  name          = "${var.environment}-mt-security-group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 3000  #grafana
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    # Prometheus (포트 9090)
    {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]  # VPC 내부 통신
    },
    # Node Exporter 및 cAdvisor (포트 9100~9323)
    {
      from_port   = 9100
      to_port     = 9323
      protocol    = "tcp"
      cidr_blocks = [module.vpc.vpc_cidr_block]  # VPC 내부 통신
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
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Redis 보안 그룹 모듈
module "redis_security_group" {
  source        = "./modules/security-group"
  name          = "${var.environment}-redis-security-group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      security_groups = [
        module.auto_scaling_be_security_group.security_group_id,
        module.auto_scaling_ai_security_group.security_group_id
      ]
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
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Jenkins 보안 그룹 모듈
module "jenkins_security_group" {
  source        = "./modules/security-group"
  name          = "${var.environment}-jenkins-security-group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = var.admin_cidr_blocks
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
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ALB 보안 그룹 모듈
module "fe_alb_security_group" {
  source        = "./modules/security-group"
  name          = "${var.environment}-fe-alb-security-group"
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
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "be_alb_security_group" {
  source        = "./modules/security-group"
  name          = "${var.environment}-be-alb-security-group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      security_groups = [module.fe_alb_security_group.security_group_id]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      security_groups = [module.fe_alb_security_group.security_group_id]
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
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Auto Scaling BE 보안 그룹 모듈
module "auto_scaling_be_security_group" {
  source        = "./modules/security-group"
  name          = "${var.environment}-auto-scaling-be-security-group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.be_alb_security_group.security_group_id]
    },
    {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = [module.be_alb_security_group.security_group_id]
    },
    {
      # Prometheus가 Spring Actuator 엔드포인트 수집 (8080 포트)
      from_port       = 8080
      to_port         = 8080
      protocol        = "tcp"
      security_groups = [module.mt_security_group.security_group_id,module.be_alb_security_group.security_group_id]
    },
    {
      # Prometheus가 Node Exporter 또는 cAdvisor 메트릭 수집 (포트 9100~9323)
      from_port       = 9100
      to_port         = 9323
      protocol        = "tcp"
      security_groups = [module.mt_security_group.security_group_id]
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
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Auto Scaling FE 보안 그룹 모듈
module "auto_scaling_fe_security_group" {
  source        = "./modules/security-group"
  name          = "${var.environment}-auto-scaling-fe-security-group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      # 배포 환경 (Production Mode)
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.fe_alb_security_group.security_group_id]
    },
    {
      # 개발 환경 (Development Mode)
      from_port       = 3000
      to_port         = 3000
      protocol        = "tcp"
      security_groups = [module.fe_alb_security_group.security_group_id]
    },
    {
      from_port       = 19100
      to_port         = 19100
      protocol        = "tcp"
      security_groups = [module.mt_security_group.security_group_id]
    }
    ,
    {
      from_port       = 18080
      to_port         = 18080
      protocol        = "tcp"
      security_groups = [module.mt_security_group.security_group_id]
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
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Auto Scaling AI 보안 그룹 모듈
module "auto_scaling_ai_security_group" {
  source        = "./modules/security-group"
  name          = "${var.environment}-auto_scaling_ai_security_group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.be_alb_security_group.security_group_id]
    },
    {
      from_port       = 5000
      to_port         = 5001
      protocol        = "tcp"
      security_groups = [module.be_alb_security_group.security_group_id]
    },
    {
      from_port       = 19100
      to_port         = 19100
      protocol        = "tcp"
      security_groups = [module.mt_security_group.security_group_id]
    }
    ,
    {
      from_port       = 18080
      to_port         = 18080
      protocol        = "tcp"
      security_groups = [module.mt_security_group.security_group_id]
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
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# NAT 인스턴스 보안 그룹 모듈
module "nat_security_group" {
  source        = "./modules/security-group"
  name          = "${var.environment}-nat-instance-sg"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    # 프라이빗 서브넷에서 NAT로 트래픽 허용 (모든 포트)
    {
      from_port       = 0
      to_port         = 65535
      protocol        = "tcp"
      cidr_blocks     = [module.vpc.vpc_cidr_block]  # VPC 전체에서 허용
    },
    # ICMP (Ping 요청 허용, 옵션)
    {
      from_port       = -1
      to_port         = -1
      protocol        = "icmp"
      cidr_blocks     = [module.vpc.vpc_cidr_block]  # VPC 내부에서만 허용
    }
  ]

  egress_rules = [
    # 모든 아웃바운드 트래픽 허용 (인터넷으로 나가기)
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


#PostgreSQL 보안그룹

module "postgres_security_group" {
  source        = "./modules/security-group"
  name          = "${var.environment}-postgres_security_group"
  vpc_id        = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      security_groups = [
        module.auto_scaling_be_security_group.security_group_id,
        module.auto_scaling_ai_security_group.security_group_id
      ]
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
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}