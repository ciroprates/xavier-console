# Criar ALB
resource "aws_lb" "main" {
  name               = "x-console-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "x-console-alb"
  }
}

# Criar target group
resource "aws_lb_target_group" "main" {
  name        = "x-console-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "x-console-tg"
  }
}

# Criar listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Security group para o ALB
resource "aws_security_group" "alb" {
  name        = "alb-sg"
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

  tags = {
    Name = "alb-sg"
  }
}

# Variables
variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs das subnets públicas"
  type        = list(string)
}

variable "container_port" {
  description = "Porta do container"
  type        = number
}

# Outputs
output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
} 