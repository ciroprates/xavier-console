module "monitoring" {
  source = "../../"

  # Configurações do CloudWatch
  cloudwatch_log_group_name = "example-log-group"
  cloudwatch_log_retention  = 30

  # Configurações do SNS
  sns_topic_name = "example-alerts"
  sns_email      = "example@example.com"

  # Configurações do CloudTrail
  cloudtrail_name = "example-trail"
  s3_bucket_name  = "example-cloudtrail-logs"

  # Configurações do GuardDuty
  guardduty_enabled = true

  # Configurações do Security Hub
  security_hub_enabled = true

  # Configurações do Config
  config_enabled = true

  # Tags
  tags = {
    Environment = "example"
    Project     = "monitoring"
  }
} 