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
module "vpc" {
  source = "../../modules/network"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# Criamos o ECS
module "ecs" {
  source = "../../modules/ecs"

  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  ecs_cluster_name    = var.ecs_cluster_name
  ecs_instance_type   = var.ecs_instance_type
  asg_min_size        = var.asg_min_size
  asg_max_size        = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity
  asg_health_check_grace_period = var.asg_health_check_grace_period
}

# Criamos o monitoramento
module "monitoring" {
  source = "../../modules/monitoring"

  budget_limit       = var.budget_limit
  notification_email = var.notification_email
}

# Criamos o IAM
module "iam" {
  source = "../../modules/iam"

  artifact_bucket_arn = var.artifact_bucket_arn
}

# Criamos o CI/CD
module "cicd" {
  source = "../../modules/cicd"

  pipeline_role_arn = module.iam.pipeline_role_arn
  artifact_bucket   = var.artifact_bucket
  repository_name   = var.repository_name
  build_project_name = var.build_project_name
  deploy_project_name = var.deploy_project_name
  approval_notification_arn = var.approval_notification_arn
} 