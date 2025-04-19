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

module "network" {
  source = "../../modules/network"
}

module "ecs" {
  source = "../../modules/ecs"
  
  vpc_id = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids
}

module "monitoring" {
  source = "../../modules/monitoring"
  
  cluster_name = var.ecs_cluster_name
  notification_email = var.notification_email
  budget_limit = var.budget_limit
} 