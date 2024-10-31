resource "aws_db_instance" "this" {
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_name                 = var.db_name
  username             = var.username
  password             = var.password
  parameter_group_name = var.parameter_group_name
  db_subnet_group_name = var.subnet_group
  vpc_security_group_ids = var.vpc_security_group_ids

  # Backups and retention
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window

  # Maintenance
  maintenance_window = var.maintenance_window

  # Multi-AZ deployment (for high availability)
  multi_az = var.multi_az

  # Performance settings
  storage_type        = var.storage_type
  max_allocated_storage = var.max_allocated_storage

  # Tags
  tags = var.tags
}