variable "budget_limit" {
  description = "The monthly budget limit in USD"
  type        = number
  default     = 100
}

variable "notification_email" {
  description = "Email address to receive budget notifications"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "Nome do grupo de logs do CloudWatch"
  type        = string
  default     = "example-log-group"
}

variable "cloudwatch_log_retention" {
  description = "Período de retenção dos logs em dias"
  type        = number
  default     = 30
}

variable "sns_topic_name" {
  description = "Nome do tópico SNS para alertas"
  type        = string
  default     = "example-alerts"
}

variable "sns_email" {
  description = "Email para receber notificações"
  type        = string
  default     = "example@example.com"
}

variable "cloudtrail_name" {
  description = "Nome da trilha do CloudTrail"
  type        = string
  default     = "example-trail"
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3 para logs do CloudTrail"
  type        = string
  default     = "example-cloudtrail-logs"
}

variable "guardduty_enabled" {
  description = "Habilitar o GuardDuty"
  type        = bool
  default     = true
}

variable "security_hub_enabled" {
  description = "Habilitar o Security Hub"
  type        = bool
  default     = true
}

variable "config_enabled" {
  description = "Habilitar o AWS Config"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default = {
    Environment = "example"
    Project     = "monitoring"
  }
} 