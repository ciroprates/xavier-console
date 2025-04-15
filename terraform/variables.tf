variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "notification_email" {
  description = "Email para notificações"
  type        = string
  sensitive   = true
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
  description = "Limite mensal do orçamento"
  type        = string
}

variable "asg_min_size" {
  description = "Número mínimo de instâncias no Auto Scaling Group"
  type        = string
}

variable "asg_max_size" {
  description = "Número máximo de instâncias no Auto Scaling Group"
  type        = string
}

variable "asg_desired_capacity" {
  description = "Capacidade desejada do Auto Scaling Group"
  type        = string
}

variable "asg_health_check_grace_period" {
  description = "Período de carência para health check do Auto Scaling Group"
  type        = string
} 