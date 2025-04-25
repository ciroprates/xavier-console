terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Criamos a VPC
module "network" {
  source = "../../modules/network"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# Criamos o ALB
module "alb" {
  source = "../../modules/alb"

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  container_port    = var.container_port
}

# Criamos o ECS
module "ecs" {
  source = "../../modules/ecs"

  ecs_cluster_name         = var.ecs_cluster_name
  ecs_instance_type        = var.ecs_instance_type
  min_capacity             = var.min_capacity
  max_capacity             = var.max_capacity
  desired_capacity         = var.desired_capacity
  vpc_id                   = module.network.vpc_id
  private_subnet_ids       = module.network.private_subnet_ids
  ecs_service_name        = var.ecs_service_name
  ecs_task_family         = var.ecs_task_family
  container_port          = var.container_port
  host_port              = var.host_port
  container_name         = var.container_name
  container_image        = var.container_image
  target_group_arn       = module.alb.target_group_arn
  ecs_role_arn           = var.ecs_role_arn
  ecs_task_execution_role_arn = var.ecs_task_execution_role_arn
  ecs_autoscale_role_arn  = var.ecs_autoscale_role_arn
  alb_security_group_id   = module.alb.alb_security_group_id
}

# Criamos o monitoramento
module "monitoring" {
  source = "../../modules/monitoring"

  budget_amount   = var.budget_amount
  email_addresses = var.email_addresses
}

# Criamos o IAM
module "iam" {
  source = "../../modules/iam"

  artifact_bucket                = var.artifact_bucket
  ecs_role_name                 = var.ecs_role_name
  codepipeline_role_name        = var.codepipeline_role_name
  codebuild_role_name           = var.codebuild_role_name
  ecs_task_execution_role_name  = var.ecs_task_execution_role_name
  ecs_autoscale_role_name       = var.ecs_autoscale_role_name
}

# Criamos o CI/CD
module "cicd" {
  source = "../../modules/cicd"

  artifact_bucket       = var.artifact_bucket
  repository_name       = var.repository_name
  github_owner         = var.github_owner
  codepipeline_role_arn = var.codepipeline_role_arn
  codebuild_role_arn    = var.codebuild_role_arn
  build_project_name    = var.build_project_name
  deploy_project_name   = var.deploy_project_name
  webhook_secret        = var.webhook_secret
  connection_arn        = var.connection_arn
}

# Outputs
output "alb_dns_name" {
  value = module.alb.alb_dns_name
} 