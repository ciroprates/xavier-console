variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Lista de CIDR blocks para subnets públicas"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Lista de CIDR blocks para subnets privadas"
  type        = list(string)
}

variable "availability_zones" {
  description = "Lista de zonas de disponibilidade"
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

variable "min_capacity" {
  description = "Capacidade mínima do Auto Scaling Group"
  type        = number
}

variable "max_capacity" {
  description = "Capacidade máxima do Auto Scaling Group"
  type        = number
}

variable "desired_capacity" {
  description = "Capacidade desejada do Auto Scaling Group"
  type        = number
}

variable "ecs_service_name" {
  description = "Nome do serviço ECS"
  type        = string
}

variable "ecs_task_family" {
  description = "Nome da família de tasks do ECS"
  type        = string
}

variable "container_port" {
  description = "Porta do container"
  type        = number
}

variable "host_port" {
  description = "Porta do host"
  type        = number
}

variable "container_name" {
  description = "Nome do container"
  type        = string
}

variable "container_image" {
  description = "Imagem do container"
  type        = string
}

variable "budget_amount" {
  description = "Valor do orçamento mensal"
  type        = number
}

variable "email_addresses" {
  description = "Lista de endereços de email para notificações"
  type        = list(string)
}

variable "artifact_bucket" {
  description = "Nome do bucket S3 para artefatos"
  type        = string
}

variable "repository_name" {
  description = "Nome do repositório GitHub"
  type        = string
}

variable "github_owner" {
  description = "Nome do dono do repositório GitHub"
  type        = string
}

variable "github_token" {
  description = "Token de acesso do GitHub"
  type        = string
  sensitive   = true
}

variable "build_project_name" {
  description = "Nome do projeto de build"
  type        = string
}

variable "deploy_project_name" {
  description = "Nome do projeto de deploy"
  type        = string
}

variable "approval_notification_arn" {
  description = "ARN do tópico SNS para notificações de aprovação"
  type        = string
} 