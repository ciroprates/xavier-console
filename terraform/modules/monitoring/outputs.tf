output "budget_id" {
  description = "O ID do orçamento criado"
  value       = aws_budgets_budget.monthly-budget.id
}

output "anomaly_monitor_id" {
  description = "O ID do monitor de anomalias criado"
  value       = aws_ce_anomaly_monitor.cost-anomaly-monitor.id
}

output "anomaly_subscription_id" {
  description = "O ID da assinatura de anomalias criada"
  value       = aws_ce_anomaly_subscription.cost-anomaly-subscription.id
} 