# Criar cluster ECS
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}

# Criar launch template
resource "aws_launch_template" "ecs" {
  name_prefix   = "ecs-launch-template-"
  image_id      = data.aws_ami.ecs.id
  instance_type = var.ecs_instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.ecs.id]
  }

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
  EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Criar Auto Scaling Group
resource "aws_autoscaling_group" "ecs" {
  name                = "ecs-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size           = var.min_capacity
  max_size           = var.max_capacity
  desired_capacity   = var.desired_capacity

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ecs.id
        version           = "$Latest"
      }

      override {
        instance_type = var.ecs_instance_type
      }
    }
  }

  health_check_type         = "EC2"
  health_check_grace_period = "300"

  tag {
    key                 = "Name"
    value              = "ecs-instance"
    propagate_at_launch = true
  }
}

# Criar security group para o ECS
resource "aws_security_group" "ecs" {
  name        = "ecs-security-group"
  description = "Security group para o ECS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.host_port
    to_port     = var.host_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group para o ALB
resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  description = "Security group para o ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criar task definition
resource "aws_ecs_task_definition" "app" {
  family                   = var.ecs_task_family
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn      = var.task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      cpu       = 256
      memory    = 512
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
resource "aws_ecs_service" "app" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_capacity

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}

# Data source para AMI do ECS
data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-arm64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
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

variable "public_subnet_ids" {
  description = "IDs das subnets públicas"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

variable "ecs_instance_type" {
  description = "Tipo de instância EC2 para o ECS"
  type        = string
  default     = "t4g.nano"
}

variable "min_capacity" {
  description = "Capacidade mínima do Auto Scaling Group"
  type        = number
}

variable "max_capacity" {
  description = "Capacidade máxima do Auto Scaling Group"
  type        = number
}

variable "desired_capacity" {
  description = "Capacidade desejada do Auto Scaling Group"
  type        = number
}

variable "ecs_instance_profile_name" {
  description = "Nome do instance profile do ECS"
  type        = string
}

variable "task_execution_role_arn" {
  description = "ARN da role de execução de task do ECS"
  type        = string
}

variable "autoscale_role_arn" {
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
  description = "ARN do target group existente"
  type        = string
} 