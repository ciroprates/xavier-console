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

variable "codepipeline_role_arn" {
  description = "ARN of the CodePipeline IAM role"
  type        = string
}

variable "codebuild_role_arn" {
  description = "ARN of the CodeBuild IAM role"
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