# Bucket S3
resource "aws_s3_bucket" "artifact_bucket" {
  bucket = var.artifact_bucket
  force_destroy = true  # Allow deletion of non-empty bucket
}

# Data sources for existing roles
data "aws_iam_role" "codepipeline_role" {
  name = var.codepipeline_role_name
}

data "aws_iam_role" "codebuild_role" {
  name = var.codebuild_role_name
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = var.ecs_task_execution_role_name
}

data "aws_iam_role" "ecs_autoscale_role" {
  name = var.ecs_autoscale_role_name
}

data "aws_iam_role" "ecs" {
  name = var.ecs_role_name
}

data "aws_iam_instance_profile" "ecs" {
  name = "ecs-instance-profile"
}

# Policy Attachments
resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  role       = data.aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = data.aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_iam_role_policy" "codebuild_ec2" {
  name = "codebuild-ec2-policy"
  role = data.aws_iam_role.codebuild_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "ec2:DescribeImages"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = data.aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_autoscale_policy" {
  role       = data.aws_iam_role.ecs_autoscale_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

# Outputs
output "codepipeline_role_arn" {
  value = data.aws_iam_role.codepipeline_role.arn
}

output "codebuild_role_arn" {
  value = data.aws_iam_role.codebuild_role.arn
}

output "ecs_task_execution_role_arn" {
  value = data.aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_autoscale_role_arn" {
  value = data.aws_iam_role.ecs_autoscale_role.arn
}

output "ecs_instance_profile_name" {
  value = data.aws_iam_instance_profile.ecs.name
}

output "task_execution_role_arn" {
  value = data.aws_iam_role.ecs_task_execution_role.arn
}

output "autoscale_role_arn" {
  value = data.aws_iam_role.ecs_autoscale_role.arn
}

# Variables
variable "artifact_bucket" {
  description = "Nome do bucket S3 para artefatos"
  type        = string
}

variable "ecs_role_name" {
  description = "Nome da role do ECS"
  type        = string
}

variable "codepipeline_role_name" {
  description = "Nome da role do CodePipeline"
  type        = string
}

variable "codebuild_role_name" {
  description = "Nome da role do CodeBuild"
  type        = string
}

variable "ecs_task_execution_role_name" {
  description = "Nome da role de execução de task do ECS"
  type        = string
}

variable "ecs_autoscale_role_name" {
  description = "Nome da role de Auto Scaling do ECS"
  type        = string
} 