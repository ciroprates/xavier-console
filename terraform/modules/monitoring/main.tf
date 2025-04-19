resource "aws_budgets_budget" "monthly-budget" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.budget_limit
  limit_unit        = "USD"
  time_period_start = "2024-01-01_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }
}

resource "aws_ce_anomaly_monitor" "cost-anomaly-monitor" {
  name              = "cost-anomaly-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "cost-anomaly-subscription" {
  name      = "cost-anomaly-subscription"
  monitor_arn_list = [aws_ce_anomaly_monitor.cost-anomaly-monitor.arn]
  threshold = 100.0

  subscriber {
    type    = "EMAIL"
    address = var.notification_email
  }
} 