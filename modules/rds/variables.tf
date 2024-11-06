variable "allocated_storage" {
  description = "The storage amount (in GB) for the DB instance."
  type        = number
  default     = 20
}

variable "engine" {
  description = "The database engine to use (e.g., mysql, postgres)"
  type        = string
}

variable "engine_version" {
  description = "The version of the database engine to use."
  type        = string
}

variable "instance_class" {
  description = "The instance type of the RDS instance (e.g., db.t3.micro)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database to create."
  type        = string
}

variable "username" {
  description = "The master username for the database."
  type        = string
}

variable "password" {
  description = "The master password for the database."
  type        = string
  sensitive   = true
}

variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate with."
  type        = string
  default     = "default"
}

variable "subnet_group" {
  description = "The name of the DB subnet group to use."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate with the RDS instance."
  type        = list(string)
}

variable "backup_retention_period" {
  description = "The backup retention period in days."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "The daily time range during which automated backups are created."
  type        = string
  default     = "07:00-09:00"
}

variable "maintenance_window" {
  description = "The weekly time range during which system maintenance can occur."
  type        = string
  default     = "Mon:03:00-Mon:04:00"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "storage_type" {
  description = "Specifies the storage type to be associated with the RDS instance."
  type        = string
  default     = "gp2"
}

variable "max_allocated_storage" {
  description = "The maximum storage threshold for RDS storage autoscaling."
  type        = number
  default     = 100
}

variable "tags" {
  description = "A map of tags to assign to the instance."
  type        = map(string)
  default     = {}
}