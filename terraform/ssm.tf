resource "aws_ssm_parameter" "ecs_cluster_name" {
  name        = "/ecs/cluster/name"
  description = "Nome do cluster ECS"
  type        = "String"
  value       = var.ecs_cluster_name
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "ecs_instance_type" {
  name        = "/ecs/instance/type"
  description = "Tipo de instância ECS"
  type        = "String"
  value       = var.ecs_instance_type
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "budget_limit" {
  name        = "/budget/monthly/limit"
  description = "Limite mensal do orçamento"
  type        = "String"
  value       = var.budget_limit
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "notification_email" {
  name        = "/notification/email"
  description = "Email para notificações"
  type        = "String"
  value       = var.notification_email
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# Auto Scaling Group Parameters
resource "aws_ssm_parameter" "asg_min_size" {
  name        = "/asg/min_size"
  description = "Número mínimo de instâncias no Auto Scaling Group"
  type        = "String"
  value       = var.asg_min_size
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "asg_max_size" {
  name        = "/asg/max_size"
  description = "Número máximo de instâncias no Auto Scaling Group"
  type        = "String"
  value       = var.asg_max_size
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "asg_desired_capacity" {
  name        = "/asg/desired_capacity"
  description = "Capacidade desejada do Auto Scaling Group"
  type        = "String"
  value       = var.asg_desired_capacity
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "asg_health_check_grace_period" {
  name        = "/asg/health_check_grace_period"
  description = "Período de carência para health check do Auto Scaling Group"
  type        = "String"
  value       = var.asg_health_check_grace_period
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
} 