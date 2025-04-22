# X-Console

Projeto de infraestrutura como código usando Terraform para provisionar recursos na AWS.

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

## Variáveis

As variáveis são definidas no arquivo `terraform/environments/prod/terraform.tfvars`:

```hcl
# Configurações da VPC
vpc_cidr             = string
public_subnet_cidrs  = list(string)
private_subnet_cidrs = list(string)
availability_zones   = list(string)

# Configurações do ECS
ecs_cluster_name                = string
ecs_instance_type              = string
asg_min_size                   = number
asg_max_size                   = number
asg_desired_capacity           = number
asg_health_check_grace_period  = number

# Configurações de Monitoramento
budget_limit       = number
notification_email = string

# Configurações do CI/CD
artifact_bucket           = string
repository_name           = string
build_project_name        = string
deploy_project_name       = string
```

## Configuração das Variáveis

1. Copie o arquivo de exemplo:
```bash
cp terraform/environments/prod/terraform.tfvars.example terraform/environments/prod/terraform.tfvars
```

2. Edite o arquivo `terraform.tfvars` com seus valores:
   - Substitua `your.email@example.com` pelo seu email para notificações
   - Substitua `your-github-username` pelo seu usuário do GitHub
   - Substitua `your-github-token` pelo seu token de acesso do GitHub
   - Ajuste os valores de CIDR e zonas de disponibilidade conforme necessário
   - Ajuste as configurações do ECS (tipo de instância, capacidade, etc.)
   - Ajuste o valor do orçamento conforme necessário

3. Valores sensíveis:
   - O arquivo `terraform.tfvars` está no `.gitignore` e não deve ser versionado
   - Tokens e credenciais devem ser mantidos seguros
   - Considere usar AWS Secrets Manager para valores sensíveis

## Pipeline de CI/CD

A pipeline é composta por três estágios:

1. **Source**: Obtém o código do CodeCommit
   - Monitora a branch `main`
   - Utiliza o repositório especificado em `RepositoryName`

2. **Build**: Executa o build com o CodeBuild
   - Valida a configuração do Terraform
   - Verifica segurança com Checkov
   - Gera o plano de execução

3. **Deploy**: Aplica as mudanças com o CodeBuild
   - Aplica o plano gerado no estágio anterior

## Como Usar

1. **Configuração Inicial**
   ```bash
   # Configure as credenciais da AWS
   aws configure

   # Clone o repositório
   git clone <url-do-repositório>
   cd x-console
   ```

2. **Criar a Pipeline**
   ```bash
   # Crie o bucket de artefatos
   aws s3api create-bucket --bucket ${artifact_bucket}

   # Implante a pipeline
   aws cloudformation deploy \
     --template-file pipeline.yml \
     --stack-name terraform-pipeline \
     --parameter-overrides RepositoryName=${repository_name}
   ```

3. **Primeiro Deploy**
   - A pipeline será criada automaticamente
   - O primeiro build será executado

## Requisitos

- AWS CLI
- Terraform >= 1.0.0
- Python 3.9
- jq 