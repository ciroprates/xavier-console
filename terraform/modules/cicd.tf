# Criar repositório CodeCommit
resource "aws_codecommit_repository" "main" {
  repository_name = var.repository_name
  description     = "Repositório principal"
}

# Criar projeto CodeBuild para build
resource "aws_codebuild_project" "build" {
  name          = var.build_project_name
  description   = "Projeto para build"
  service_role  = var.codebuild_role_arn
  build_timeout = "5"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENVIRONMENT"
      value = "prod"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec.yml")
  }
}

# Criar projeto CodeBuild para deploy
resource "aws_codebuild_project" "deploy" {
  name          = var.deploy_project_name
  description   = "Projeto para deploy"
  service_role  = var.codebuild_role_arn
  build_timeout = "5"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENVIRONMENT"
      value = "prod"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline.yml")
  }
}

# Pipeline de CI/CD
resource "aws_codepipeline" "terraform_pipeline" {
  name     = "terraform-infrastructure-pipeline"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.artifact_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.repository_name
        Branch     = "main"
        OAuthToken = var.github_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.terraform_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.terraform_build.name
      }
    }
  }
}

# Projeto CodeBuild
resource "aws_codebuild_project" "terraform_build" {
  name          = "terraform-prod-build"
  service_role  = var.codebuild_role_arn
  build_timeout = "5"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "ENVIRONMENT"
      value = "prod"
    }

    environment_variable {
      name  = "TF_WORKSPACE"
      value = "prod"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/../../buildspec.yml")
  }
}

# Variáveis
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

variable "codepipeline_role_arn" {
  description = "ARN da role do CodePipeline"
  type        = string
}

variable "codebuild_role_arn" {
  description = "ARN da role do CodeBuild"
  type        = string
} 