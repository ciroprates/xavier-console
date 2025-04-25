# X-Console - Infraestrutura como Código

Este projeto contém a infraestrutura como código (IaC) para o X-Console, utilizando Terraform.

## Estrutura do Projeto

```
terraform/
├── environments/     # Configurações específicas por ambiente
├── modules/         # Módulos reutilizáveis
└── .terraform/      # Diretório de cache do Terraform
```

## Pré-requisitos

- Terraform >= 1.0.0
- AWS CLI configurado
- Acesso ao AWS Parameter Store

## Configuração do Ambiente

1. Configure suas credenciais AWS:
```bash
aws configure
```

2. Instale as dependências do Terraform:
```bash
cd terraform
terraform init
```

## Persistindo Variáveis no Parameter Store

Para persistir as variáveis do Terraform no AWS Parameter Store, siga estes passos:

1. Crie um arquivo `terraform.tfvars` com suas variáveis:
```hcl
environment = "dev"
region     = "us-east-1"
# ... outras variáveis
```

2. Use o AWS CLI para armazenar as variáveis no Parameter Store:
```bash
# Para variáveis individuais
aws ssm put-parameter \
    --name "/x-console/terraform/environment" \
    --value "dev" \
    --type "String" \
    --overwrite

# Para múltiplas variáveis de um arquivo
aws ssm put-parameter \
    --name "/x-console/terraform/tfvars" \
    --value "$(cat terraform.tfvars)" \
    --type "String" \
    --overwrite
```

3. Para recuperar as variáveis no Terraform, adicione o seguinte bloco no seu arquivo `main.tf`:
```hcl
data "aws_ssm_parameter" "tfvars" {
  name = "/x-console/terraform/tfvars"
}

locals {
  tfvars = jsondecode(data.aws_ssm_parameter.tfvars.value)
}
```

## Comandos Úteis

- Inicializar o Terraform:
```bash
terraform init
```

- Verificar o plano de execução:
```bash
terraform plan
```

- Aplicar as mudanças:
```bash
terraform apply
```

- Destruir a infraestrutura:
```bash
terraform destroy
```

## Convenções de Nomenclatura

- Use o prefixo `/x-console/terraform/` para todas as variáveis no Parameter Store
- Mantenha os nomes das variáveis em minúsculas e use hífens para separar palavras
- Documente todas as variáveis no arquivo `variables.tf`

## Segurança

- Nunca comite arquivos `.tfvars` no repositório
- Use o Parameter Store para armazenar valores sensíveis
- Aplique o princípio do menor privilégio nas políticas IAM

## Suporte

Para questões ou problemas, abra uma issue no repositório do projeto. 