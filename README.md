# Configuração do Terraform

Este diretório contém a configuração da infraestrutura AWS usando Terraform.

## Pré-requisitos

- Terraform instalado
- AWS CLI configurado com credenciais válidas
- Acesso à conta AWS com permissões adequadas

## Configuração Inicial

1. Copie o arquivo de exemplo para criar seu arquivo de variáveis:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edite o arquivo `terraform.tfvars` com seus valores:
   - Configure o email para notificações
   - Ajuste os limites de orçamento
   - Defina as configurações do cluster ECS
   - Configure os parâmetros do Auto Scaling Group

3. Inicialize o Terraform:
   ```bash
   terraform init
   ```

4. Aplique a configuração:
   ```bash
   terraform apply
   ```

## Estrutura de Arquivos

- `providers.tf`: Configuração dos providers AWS
- `network.tf`: Configuração de VPC e subnets
- `iam.tf`: Configuração de roles e políticas IAM
- `ecs.tf`: Configuração do cluster ECS
- `ssm.tf`: Parâmetros do SSM Parameter Store
- `cost_monitoring.tf`: Configuração de monitoramento de custos
- `variables.tf`: Definição das variáveis
- `terraform.tfvars.example`: Template para configuração das variáveis

## Segurança

- O arquivo `terraform.tfvars` está no .gitignore para proteger informações sensíveis
- Nunca comite o arquivo `terraform.tfvars` no repositório
- Mantenha suas credenciais AWS seguras 