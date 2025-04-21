# Criar cluster ECS
resource "aws_ecs_cluster" "main" {
  name = var.ecs_cluster_name
}

# Criar launch configuration
resource "aws_launch_configuration" "ecs" {
  name_prefix          = "ecs-launch-config-"
  image_id            = data.aws_ami.ecs.id
  instance_type       = var.ecs_instance_type
  security_groups     = [aws_security_group.ecs.id]
  iam_instance_profile = var.ecs_instance_profile_name
  user_data           = <<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Criar Auto Scaling Group
resource "aws_autoscaling_group" "ecs" {
  name                 = "ecs-asg"
  launch_configuration = aws_launch_configuration.ecs.name
  vpc_zone_identifier  = var.private_subnet_ids
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity

  health_check_type         = "EC2"
  health_check_grace_period = var.asg_health_check_grace_period

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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data source para AMI do ECS
data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Variáveis
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

variable "ecs_instance_type" {
  description = "Tipo de instância EC2 para o ECS"
  type        = string
}

variable "asg_min_size" {
  description = "Tamanho mínimo do Auto Scaling Group"
  type        = string
}

variable "asg_max_size" {
  description = "Tamanho máximo do Auto Scaling Group"
  type        = string
}

variable "asg_desired_capacity" {
  description = "Capacidade desejada do Auto Scaling Group"
  type        = string
}

variable "asg_health_check_grace_period" {
  description = "Período de carência para health check"
  type        = string
}

variable "ecs_instance_profile_name" {
  description = "Nome do instance profile do ECS"
  type        = string
} 