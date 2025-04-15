# Get latest ECS-optimized AMI
data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

# Create ECS Cluster
resource "aws_ecs_cluster" "fargate_cluster" {
  name = aws_ssm_parameter.ecs_cluster_name.value

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "fargate-spot-cluster"
  }
}

# Create Launch Template
resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-fargate-spot"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = aws_ssm_parameter.ecs_instance_type.value

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ecs_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ssm_parameter.ecs_cluster_name.value} >> /etc/ecs/ecs.config
    echo ECS_ENABLE_SPOT_INSTANCE_DRAINING=true >> /etc/ecs/ecs.config
  EOF
  )
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "ecs_asg" {
  name                = "ecs-fargate-spot-asg"
  vpc_zone_identifier = [aws_subnet.private_subnet.id]
  min_size            = tonumber(aws_ssm_parameter.asg_min_size.value)
  max_size            = tonumber(aws_ssm_parameter.asg_max_size.value)
  desired_capacity    = tonumber(aws_ssm_parameter.asg_desired_capacity.value)
  health_check_grace_period = tonumber(aws_ssm_parameter.asg_health_check_grace_period.value)
  protect_from_scale_in = false

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value              = true
    propagate_at_launch = true
  }
}

# Create ECS Capacity Provider
resource "aws_ecs_capacity_provider" "fargate_spot" {
  name = "spot-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

# Associate Capacity Provider with Cluster
resource "aws_ecs_cluster_capacity_providers" "example" {
  cluster_name = aws_ecs_cluster.fargate_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.fargate_spot.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.fargate_spot.name
  }
} 