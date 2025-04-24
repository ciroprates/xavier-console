# X-Console

![Pipeline Status](https://github.com/ciroprates/xavier-console/actions/workflows/main.yml/badge.svg)

Projeto de infraestrutura como código (IaC) usando Terraform para provisionar e gerenciar recursos na AWS de forma automatizada e segura.

## Objetivos

- Automatizar o provisionamento de infraestrutura na AWS usando Terraform
- Implementar uma pipeline de CI/CD robusta para deploy contínuo
- Gerenciar recursos de forma segura e escalável
- Monitorar custos e performance da infraestrutura

## Estrutura do Projeto

```
.
├── README.md
├── .github/
│   └── workflows/
│       └── main.yml
└── terraform/
    ├── environments/
    │   └── prod/
    │       ├── main.tf
    │       ├── terraform.tfvars
    │       ├── terraform.tfvars.example
    │       └── variables.tf
    └── modules/
        ├── cicd/
        │   ├── main.tf
        │   ├── buildspec.yml
        │   ├── pipeline.yml
        │   └── variables.tf
        ├── ecs/
        │   ├── main.tf
        │   └── variables.tf
        ├── iam/
        │   ├── main.tf
        │   └── variables.tf
        ├── monitoring/
        │   ├── main.tf
        │   └── variables.tf
        └── network/
            ├── main.tf
            └── variables.tf
```

## Módulos

- **Network**: Configuração de VPC, subnets e grupos de segurança
- **ECS**: Cluster ECS Fargate e Auto Scaling Group
- **Monitoring**: Configuração de orçamento e notificações
- **IAM**: Políticas e roles para a pipeline
- **CI/CD**: Configuração da pipeline de deploy

## Configuração

1. **Configuração Inicial**
   ```bash
   # Configure as credenciais da AWS
   aws configure

   # Clone o repositório
   git clone <url-do-repositório>
   cd x-console
   ```

2. **Configurar Variáveis**
   ```bash
   cp terraform/environments/prod/terraform.tfvars.example terraform/environments/prod/terraform.tfvars
   ```
   
   Edite o arquivo `terraform.tfvars` com suas configurações:
   - Email para notificações
   - Credenciais do GitHub
   - Configurações de rede (CIDR, zonas de disponibilidade)
   - Configurações do ECS
   - Limite de orçamento

3. **Configurar Parameter Store**
   ```bash
   # Criar o parâmetro no SSM Parameter Store
   aws ssm put-parameter \
     --name "/terraform/vars" \
     --type "SecureString" \
     --value "$(cat terraform/environments/prod/terraform.tfvars)" \
     --overwrite
   ```

   > **Nota**: O arquivo `terraform.tfvars` está no `.gitignore` e não deve ser versionado. O conteúdo é armazenado de forma segura no Parameter Store.

## Pipeline de CI/CD

A pipeline é composta por três estágios:

1. **Source**: Obtém o código do repositório
2. **Build**: 
   - Recupera as variáveis do Parameter Store
   - Valida a configuração do Terraform
   - Gera o plano de execução
3. **Deploy**: Aplica as mudanças de forma automatizada

## Configuração de Webhooks

Para configurar os webhooks da pipeline com AWS CLI, siga os passos abaixo:

1. **Obter o ARN e URL do webhook**
   ```bash
   # Lista os webhooks existentes
   aws codepipeline list-webhooks

   # Ou crie um novo webhook
   aws codepipeline create-webhook \
     --cli-input-json '{
       "webhook": {
         "name": "x-console-webhook",
         "targetPipeline": "x-console-pipeline",
         "targetAction": "Source",
         "filters": [{
           "jsonPath": "$.ref",
           "matchEquals": "refs/heads/main"
         }],
         "authentication": "GITHUB_HMAC",
         "authenticationConfiguration": {
           "SecretToken": "seu-token-secreto"
         }
       }
     }'

   # Obter a URL do webhook
   aws codepipeline get-webhook \
     --webhook-name "x-console-webhook" \
     --query 'webhook.url' \
     --output text
   ```

2. **Registrar o webhook no GitHub**
   ```bash
   # Registra o webhook no GitHub usando o ARN obtido
   aws codepipeline register-webhook-with-third-party \
     --webhook-name "x-console-webhook"

   # Configure o webhook no GitHub usando a URL obtida
   # Acesse: https://github.com/seu-usuario/seu-repositorio/settings/hooks
   # Clique em "Add webhook"
   # Cole a URL do webhook no campo "Payload URL"
   # Selecione "application/json" como Content type
   # Cole o mesmo Secret Token usado na criação do webhook
   # Selecione "Just the push event"
   # Clique em "Add webhook"
   ```

3. **Verificar status do webhook**
   ```bash
   # Verifica se o webhook está ativo
   aws codepipeline get-webhook \
     --webhook-name "x-console-webhook"
   ```

> **Nota**: Substitua `seu-token-secreto` por um token seguro gerado para seu webhook. O token deve ser armazenado de forma segura.

## Deploy

- Faça commit das alterações na branch main
- A pipeline será executada automaticamente
- O deploy será realizado de forma automatizada

## Requisitos

- AWS CLI
- Terraform >= 1.0.0
- Python 3.9
- jq 