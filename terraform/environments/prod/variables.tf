variable "notification_email" {
  description = "Email para notificações"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

variable "ecs_instance_type" {
  description = "Tipo de instância ECS"
  type        = string
}

variable "budget_limit" {
  description = "Limite de orçamento mensal"
  type        = string
}

variable "asg_min_size" {
  description = "Número mínimo de instâncias no ASG"
  type        = string
}

variable "asg_max_size" {
  description = "Número máximo de instâncias no ASG"
  type        = string
}

variable "asg_desired_capacity" {
  description = "Número desejado de instâncias no ASG"
  type        = string
}

variable "asg_health_check_grace_period" {
  description = "Período de carência para health check do ASG"
  type        = string
} 