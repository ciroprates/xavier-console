output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = aws_ssm_parameter.ecs_cluster_name.value
  sensitive   = true
}

output "ecs_instance_type" {
  description = "Tipo de instância ECS"
  value       = aws_ssm_parameter.ecs_instance_type.value
  sensitive   = true
}

output "asg_name" {
  description = "Nome do Auto Scaling Group"
  value       = aws_autoscaling_group.ecs_asg.name
}

output "budget_name" {
  description = "Nome do budget mensal"
  value       = aws_budgets_budget.monthly.name
}

output "anomaly_monitor_name" {
  description = "Nome do monitor de anomalias"
  value       = aws_ce_anomaly_monitor.anomaly_monitor.name
} 