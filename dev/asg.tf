module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.0.1"

  for_each = {
    frontend = {
      network_interfaces = [
        {
          associate_public_ip_address = true
          security_groups             = [module.autoscaling_sg_frontend.security_group_id]
        }
      ]
      instance_type              = var.ecs_instance_type
      use_mixed_instances_policy = false
      mixed_instances_policy     = {}
      user_data                  = <<-EOT
        #!/bin/bash

        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${var.cluster_name}
        ECS_LOGLEVEL=debug
        ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(var.frontend_tags)}
        ECS_ENABLE_TASK_IAM_ROLE=true
        EOF
      EOT
      tags = var.frontend_tags
    }
    backend = {
      network_interfaces = [
        {
          associate_public_ip_address = true
          security_groups             = [module.autoscaling_sg_backend.security_group_id]
        }
      ]
      instance_type              = var.ecs_instance_type
      use_mixed_instances_policy = false
      mixed_instances_policy     = {}
      user_data                  = <<-EOT
        #!/bin/bash

        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${var.cluster_name}
        ECS_LOGLEVEL=debug
        ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(var.backend_tags)}
        ECS_ENABLE_TASK_IAM_ROLE=true
        EOF
      EOT
      tags = var.backend_tags
    }
  }

  name = "${var.Name}-${each.key}"
  key_name = var.key_name

  image_id      = "ami-012880a6f6805d019"
  instance_type = each.value.instance_type
  user_data     = base64encode(each.value.user_data)
  network_interfaces = each.value.network_interfaces
  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = var.Name
  iam_role_description        = "ECS role for ${var.Name}"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEC2RoleforSSM                 = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  }

  vpc_zone_identifier = module.vpc.public_subnets
  health_check_type   = "EC2"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  protect_from_scale_in = false

  tags = each.value.tags
}

################################################################################
# security group for autoscaling group frontend
################################################################################

module "autoscaling_sg_frontend" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.Name}-frontend"
  description = "Frontend autoscaling group security group"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_frontend.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
  
  ingress_with_cidr_blocks = [
    {
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]

  tags = var.frontend_tags
}

################################################################################
# security group for autoscaling group backend
################################################################################

module "autoscaling_sg_backend" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.Name}-backend"
  description = "Backend autoscaling group security group"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_backend.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
  
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]

  tags = var.backend_tags
}