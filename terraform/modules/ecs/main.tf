# Criar cluster ECS
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}

# Criar task definition
resource "aws_ecs_task_definition" "main" {
  family                   = var.ecs_task_family
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512
  execution_role_arn      = var.ecs_task_execution_role_arn
  task_role_arn           = var.ecs_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# Criar serviço ECS
resource "aws_ecs_service" "main" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_capacity
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }
}

# Criar Auto Scaling
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn          = var.ecs_autoscale_role_arn
}

# Security group para as tasks do ECS
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "Security group para as tasks do ECS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.host_port
    to_port         = var.host_port
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Variables
variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

variable "desired_capacity" {
  description = "Número desejado de tasks"
  type        = number
}

variable "min_capacity" {
  description = "Capacidade mínima do Auto Scaling"
  type        = number
}

variable "max_capacity" {
  description = "Capacidade máxima do Auto Scaling"
  type        = number
}

variable "ecs_instance_type" {
  description = "Tipo de instância para o ECS"
  type        = string
}

variable "ecs_role_arn" {
  description = "ARN da role do ECS"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN da role de execução de task do ECS"
  type        = string
}

variable "ecs_autoscale_role_arn" {
  description = "ARN da role de Auto Scaling do ECS"
  type        = string
}

variable "ecs_service_name" {
  description = "Nome do serviço ECS"
  type        = string
}

variable "ecs_task_family" {
  description = "Nome da família de task do ECS"
  type        = string
}

variable "container_port" {
  description = "Porta do container"
  type        = number
}

variable "host_port" {
  description = "Porta do host"
  type        = number
}

variable "container_name" {
  description = "Nome do container"
  type        = string
}

variable "container_image" {
  description = "Imagem do container"
  type        = string
}

variable "target_group_arn" {
  description = "ARN do target group"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID do security group do ALB"
  type        = string
} 