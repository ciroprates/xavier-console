variable "notification_email" {
  description = "O email para receber notificações de orçamento e anomalias"
  type        = string
}

variable "budget_limit" {
  description = "O limite de orçamento mensal em USD"
  type        = number
  default     = 1000
} 