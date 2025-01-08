################################################################################
# Cluster
################################################################################

module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = var.cluster_name

  # Capacity provider - autoscaling groups
  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    # On-demand instances
    frontend = {
      auto_scaling_group_arn         = module.autoscaling["frontend"].autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 2
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 100
      }

      default_capacity_provider_strategy = {
        weight = 1
        base   = 1
      }
    }
    backend = {
      auto_scaling_group_arn         = module.autoscaling["backend"].autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 2
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 100
      }

      default_capacity_provider_strategy = {
        weight = 1
        base   = 1
      }
    }
  }

  tags = var.ecs_tags
}

################################################################################
# Service frontend
################################################################################

module "ecs_service_frontend" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  # Service
  name        = var.frontend_service_name
  cluster_arn = module.ecs_cluster.arn
  # Task Definition
  requires_compatibilities = ["EC2"]
  launch_type              = "EC2"
  cpu                      = null
  memory                   = null
  capacity_provider_strategy = {
    frontend = {
      capacity_provider = module.ecs_cluster.autoscaling_capacity_providers["frontend"].name
      weight            = 1
      base              = 1
    }
  }
  network_mode = "bridge"

  # Container definition(s)
  container_definitions = {
    (var.frontend_service_name) = {
      image = var.frontend_image
      name      = "frontend"
      cpu       = 512
      memory    = 512
      essential = true
      port_mappings = [
        {
          name          = var.frontend_service_name
          containerPort = var.frontend_port
          hostPort      = var.frontend_port
          protocol      = "tcp"
        }
      ]

      readonly_root_filesystem = false

      enable_cloudwatch_logging              = true
      create_cloudwatch_log_group            = true
      cloudwatch_log_group_name              = "/aws/ecs/${var.Name}/${var.frontend_service_name}"
      cloudwatch_log_group_retention_in_days = 7

      log_configuration = {
        logDriver = "awslogs"
      }
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb_frontend.target_groups[var.frontend_target_group].arn
      container_name   = var.frontend_service_name
      container_port   = var.frontend_port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_http_ingress = {
      type                     = "ingress"
      from_port                = var.frontend_port
      to_port                  = var.frontend_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb_frontend.security_group_id
    }
  }

  tags = var.frontend_tags
}

################################################################################
# Service backend
################################################################################

module "ecs_service_backend" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  # Service
  name        = var.backend_service_name
  cluster_arn = module.ecs_cluster.arn
  # Task Definition
  requires_compatibilities = ["EC2"]
  launch_type              = "EC2"
  cpu                      = null
  memory                   = null
  capacity_provider_strategy = {
    backend = {
      capacity_provider = module.ecs_cluster.autoscaling_capacity_providers["backend"].name
      weight            = 1
      base              = 1
    }
  }
  network_mode = "bridge"

  # Container definition(s)
  container_definitions = {
    (var.backend_service_name) = {
      image = var.backend_image
      name      = "backend"
      cpu       = 512
      memory    = 512
      essential = true
      port_mappings = [
        {
          name          = var.backend_service_name
          containerPort = var.backend_port
          hostPort      = var.backend_port
          protocol      = "tcp"
        }
      ]

      readonly_root_filesystem = false

      enable_cloudwatch_logging              = true
      create_cloudwatch_log_group            = true
      cloudwatch_log_group_name              = "/aws/ecs/${var.Name}/${var.backend_service_name}"
      cloudwatch_log_group_retention_in_days = 7

      log_configuration = {
        logDriver = "awslogs"
      }
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb_backend.target_groups[var.backend_target_group].arn
      container_name   = var.backend_service_name
      container_port   = var.backend_port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_http_ingress = {
      type                     = "ingress"
      from_port                = var.backend_port
      to_port                  = var.backend_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb_backend.security_group_id
    }
  }

  tags = var.backend_tags
}
