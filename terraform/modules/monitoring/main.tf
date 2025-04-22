# Criar tópico SNS para notificações
resource "aws_sns_topic" "budget" {
  name = "budget-notifications"
}

# Criar subscription para o tópico SNS
resource "aws_sns_topic_subscription" "budget" {
  count     = length(var.email_addresses)
  topic_arn = aws_sns_topic.budget.arn
  protocol  = "email"
  endpoint  = var.email_addresses[count.index]
}

# Criar CloudWatch Alarm para custo
resource "aws_cloudwatch_metric_alarm" "budget" {
  alarm_name          = "budget-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period             = "21600"
  statistic          = "Maximum"
  threshold          = var.budget_amount
  alarm_description  = "Alarme para monitoramento de custos"
  alarm_actions      = [aws_sns_topic.budget.arn]

  dimensions = {
    Currency = "USD"
  }
}

# Variables
variable "budget_amount" {
  description = "Valor do orçamento mensal"
  type        = number
}

variable "email_addresses" {
  description = "Lista de endereços de email para notificações"
  type        = list(string)
} 