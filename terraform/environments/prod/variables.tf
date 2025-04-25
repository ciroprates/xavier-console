variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_instance_type" {
  description = "Instance type for ECS container instances"
  type        = string
}

variable "min_capacity" {
  description = "Minimum number of instances in the ECS cluster"
  type        = number
}

variable "max_capacity" {
  description = "Maximum number of instances in the ECS cluster"
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances in the ECS cluster"
  type        = number
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "ecs_task_family" {
  description = "Name of the ECS task family"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "host_port" {
  description = "Port exposed by the host"
  type        = number
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

variable "budget_amount" {
  description = "Budget amount in USD"
  type        = number
}

variable "email_addresses" {
  description = "Email addresses for budget notifications"
  type        = list(string)
}

variable "artifact_bucket" {
  description = "Name of the S3 bucket to store artifacts"
  type        = string
}

variable "repository_name" {
  description = "Name of the GitHub repository"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "build_project_name" {
  description = "Name of the CodeBuild project for building"
  type        = string
}

variable "deploy_project_name" {
  description = "Name of the CodeBuild project for deploying"
  type        = string
}

variable "webhook_secret" {
  description = "Secret token for GitHub webhook"
  type        = string
}

variable "connection_arn" {
  description = "ARN of the CodeStar connection to GitHub"
  type        = string
}

variable "ecs_role_name" {
  description = "Name of the ECS role"
  type        = string
}

variable "codepipeline_role_name" {
  description = "Name of the CodePipeline role"
  type        = string
}

variable "codebuild_role_name" {
  description = "Name of the CodeBuild role"
  type        = string
}

variable "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  type        = string
}

variable "ecs_autoscale_role_name" {
  description = "Name of the ECS autoscale role"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the CodePipeline role"
  type        = string
}

variable "codebuild_role_arn" {
  description = "ARN of the CodeBuild role"
  type        = string
}

variable "ecs_role_arn" {
  description = "ARN of the ECS role"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecs_autoscale_role_arn" {
  description = "ARN of the ECS autoscale role"
  type        = string
} 