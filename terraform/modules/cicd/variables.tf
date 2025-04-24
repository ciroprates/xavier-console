variable "artifact_bucket" {
  description = "Nome do bucket S3 para armazenar os artefatos"
  type        = string
}

variable "repository_name" {
  description = "Nome do repositório no GitHub"
  type        = string
}

variable "github_owner" {
  description = "Nome do dono do repositório GitHub"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN da role do CodePipeline"
  type        = string
}

variable "codebuild_role_arn" {
  description = "ARN da role do CodeBuild"
  type        = string
}

variable "build_project_name" {
  description = "Nome do projeto de build"
  type        = string
}

variable "deploy_project_name" {
  description = "Nome do projeto de deploy"
  type        = string
}

variable "connection_arn" {
  description = "ARN da conexão CodeStar com o GitHub"
  type        = string
}

variable "webhook_secret" {
  description = "Secret para o webhook do GitHub"
  type        = string
  sensitive   = true
} 