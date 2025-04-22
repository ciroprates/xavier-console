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

# Criar budget
resource "aws_budgets_budget" "monthly" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.budget_amount
  limit_unit        = "USD"
  time_period_start = "2023-01-01_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = var.email_addresses
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "FORECASTED"
    subscriber_email_addresses = var.email_addresses
  }
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