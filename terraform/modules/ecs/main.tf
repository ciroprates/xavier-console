resource "aws_ecs_cluster" "fargate_cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.fargate_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.fargate_spot.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.fargate_spot.name
  }
}

resource "aws_ecs_capacity_provider" "fargate_spot" {
  name = "spot-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                = "ecs-fargate-spot-asg"
  vpc_zone_identifier = var.subnet_ids
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  health_check_grace_period = var.asg_health_check_grace_period
}

resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-fargate-spot"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.ecs_sg.id]
  }
}

data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-security-group"
  description = "Security group for ECS instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
} 