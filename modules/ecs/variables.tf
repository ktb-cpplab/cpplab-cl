variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "container_cpu" {
  description = "CPU units for the container"
  type        = number
}

variable "container_memory" {
  description = "Memory (MiB) for the container"
  type        = number
}

variable "container_port" {
  description = "Port of the container"
  type        = number
}

variable "host_port" {
  description = "Port on the host"
  type        = number
}

variable "desired_count" {
  description = "Desired number of running tasks"
  type        = number
}

variable "subnet_ids" {
  description = "Subnet IDs for the network configuration"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of Target Group ARNs"
  type        = list(string)
}
