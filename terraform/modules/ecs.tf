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
  iam_instance_profile = aws_iam_instance_profile.ecs.name
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

# Criar IAM role para o ECS
resource "aws_iam_role" "ecs" {
  name = "ecs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Criar IAM instance profile para o ECS
resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs.name
}

# Criar IAM policy para o ECS
resource "aws_iam_role_policy" "ecs" {
  name = "ecs-policy"
  role = aws_iam_role.ecs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:CreateCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTelemetrySession",
          "ecs:Submit*",
          "ecs:StartTask",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
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