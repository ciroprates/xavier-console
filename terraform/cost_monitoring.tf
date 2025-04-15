# Create Cost Budget
resource "aws_budgets_budget" "monthly" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = aws_ssm_parameter.budget_limit.value
  limit_unit        = "USD"
  time_period_start = "2024-01-01_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [aws_ssm_parameter.notification_email.value]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [aws_ssm_parameter.notification_email.value]
  }
}

# Create Cost Anomaly Detection
resource "aws_ce_anomaly_monitor" "anomaly_monitor" {
  name              = "cost-anomaly-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "anomaly_subscription" {
  name      = "cost-anomaly-subscription"
  monitor_arn_list = [
    aws_ce_anomaly_monitor.anomaly_monitor.arn
  ]
  frequency = "DAILY"

  subscriber {
    type    = "EMAIL"
    address = aws_ssm_parameter.notification_email.value
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      match_options = ["GREATER_THAN_OR_EQUAL"]
      values        = ["100"]
    }
  }
} 