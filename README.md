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
├── buildspec.yml
├── pipeline.yml
├── .gitignore
└── terraform/
    ├── environments/
    │   └── prod/
    │       ├── main.tf
    │       ├── terraform.tfvars
    │       └── terraform.tfvars.example
    └── modules/
        ├── cicd.tf
        ├── ecs.tf
        ├── iam.tf
        ├── monitoring.tf
        └── network.tf
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

   > **Nota**: O arquivo `terraform.tfvars` está no `.gitignore` e não deve ser versionado.

## Pipeline de CI/CD

A pipeline é composta por três estágios:

1. **Source**: Obtém o código do repositório
2. **Build**: Valida a configuração do Terraform e gera o plano de execução
3. **Deploy**: Aplica as mudanças de forma automatizada

## Deploy

- Faça commit das alterações na branch main
- A pipeline será executada automaticamente
- O deploy será realizado de forma automatizada

## Requisitos

- AWS CLI
- Terraform >= 1.0.0
- Python 3.9
- jq 