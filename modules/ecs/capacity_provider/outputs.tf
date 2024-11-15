# /modules/ecs/capacity_provider/outputs.tf
output "name" {
  description = "The name of the ECS Capacity Provider"
  value       = aws_ecs_capacity_provider.this.name
}