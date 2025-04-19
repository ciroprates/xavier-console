# Xavier-Console Infrastructure

Este projeto contém a configuração da infraestrutura AWS usando Terraform, incluindo módulos para monitoramento, rede e ECS.

## Módulos Disponíveis

### Monitoramento
- Configuração de orçamento mensal com notificações
- Monitoramento de anomalias de custo
- Notificações via email para alertas de orçamento e anomalias

### Rede
- VPC com suporte a DNS
- Subnets privadas em múltiplas AZs disponíveis
- Tags padrão para recursos

### ECS
- Cluster Fargate com suporte a Spot para otimização de custos
- Auto Scaling Group com configurações personalizáveis
- Security Groups com regras básicas de rede
- Container Insights habilitado para monitoramento
- Launch Template com AMI otimizada para ECS

## Pipeline de CI/CD

O projeto utiliza AWS CodePipeline para automatizar o processo de implantação, com stages separados para desenvolvimento e produção.

### Estrutura do Pipeline

1. **Source Stage**
   - Monitora a branch `develop` no CodeCommit para desenvolvimento
   - Monitora a branch `master` no CodeCommit para produção
   - Dispara o pipeline automaticamente quando há mudanças

2. **Dev Stage**
   - Executa o projeto `terraform-dev-build`
   - Usa o arquivo `buildspec.yml`
   - Aplica mudanças automaticamente no ambiente de dev
   - Valida a configuração do Terraform
   - Verifica segurança com Checkov
   - Usa workspace `dev` do Terraform

3. **Approval Stage**
   - Requer aprovação manual para prosseguir
   - Envia notificação via SNS
   - Permite revisão das mudanças antes da produção

4. **Prod Stage**
   - Executa o projeto `terraform-prod-build`
   - Usa o arquivo `buildspec.prod.yml`
   - Requer aprovação manual para aplicar mudanças
   - Usa workspace `prod` do Terraform

### Como Usar o Pipeline

1. **Desenvolvimento**
   ```bash
   # Faça suas alterações na branch develop
   git checkout develop
   git add .
   git commit -m "Descrição das mudanças"
   git push origin develop
   ```
   - O pipeline rodará automaticamente em dev
   - As mudanças serão aplicadas após validação

2. **Produção**
   - Após sucesso em dev, o pipeline aguardará aprovação
   - Receba a notificação no tópico SNS
   - Revise as mudanças no console do CodePipeline
   - Aprove ou rejeite a implantação em produção
   - Após aprovação, as mudanças serão aplicadas na branch master

### Disparando Mudanças em Produção

Todas as mudanças em produção devem passar pelo pipeline de CI/CD para garantir a qualidade e segurança do ambiente.

1. **Fluxo de Implantação**
   - Após o sucesso do pipeline em dev, você receberá uma notificação SNS
   - Acesse o console do AWS CodePipeline
   - Localize o pipeline `terraform-infrastructure-pipeline`
   - Na etapa de aprovação, você verá:
     - O plano de execução do Terraform
     - As mudanças que serão aplicadas
     - Um botão para aprovar ou rejeitar
   - Clique em "Aprovar" para iniciar a implantação em produção
   - O pipeline continuará automaticamente para o stage de produção
   - As mudanças serão aplicadas na branch master

2. **Monitorando a Implantação**
   - Acesse o console do AWS CodePipeline
   - Selecione o pipeline `terraform-infrastructure-pipeline`
   - Na etapa de produção, você verá:
     - O status da execução
     - Logs detalhados do CodeBuild
     - Resultado da validação do Terraform
     - Resultado da verificação de segurança
   - Após a conclusão, você receberá uma notificação SNS

3. **Em Caso de Falha**
   - O pipeline parará automaticamente
   - Você receberá uma notificação de falha
   - Revise os logs para identificar o problema
   - Corrija o problema e reinicie o pipeline
   - Se necessário, faça rollback manual usando o Terraform

## Testando Localmente

Para testar as configurações localmente antes de enviar para o pipeline, siga os passos abaixo:

1. **Configuração do Ambiente**
   ```bash
   # Instale o Terraform
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install terraform

   # Instale o Checkov para validação de segurança
   pip install checkov
   ```

2. **Inicialização do Terraform**
   ```bash
   # Navegue até o diretório do módulo que deseja testar
   cd terraform/modules/monitoring/examples/simple

   # Inicialize o Terraform
   terraform init

   # Selecione o workspace de desenvolvimento
   terraform workspace select dev
   ```

3. **Testando as Configurações**
   ```bash
   # Valide a configuração
   terraform validate

   # Verifique a segurança com Checkov
   checkov -d .

   # Visualize as mudanças que serão aplicadas
   terraform plan

   # Aplique as mudanças (opcional)
   terraform apply
   ```

4. **Testando Múltiplos Ambientes**
   ```bash
   # Para testar em produção
   terraform workspace select prod
   terraform plan

   # Para voltar para desenvolvimento
   terraform workspace select dev
   ```

5. **Limpeza após os Testes**
   ```bash
   # Destrua os recursos criados
   terraform destroy

   # Remova o cache do Terraform
   rm -rf .terraform
   rm -f .terraform.lock.hcl
   ```

6. **Dicas para Testes Locais**
   - Use `terraform plan -out=tfplan` para salvar o plano e revisá-lo
   - Adicione `-var-file=dev.tfvars` para usar variáveis específicas
   - Use `terraform state list` para ver os recursos gerenciados
   - Verifique os logs com `terraform console` para debug

7. **Testes Automatizados**
   ```bash
   # Execute os testes do projeto
   cd test
   go test -v ./...
   ```

8. **Validação de Segurança**
   ```bash
   # Execute o Checkov com regras específicas
   checkov -d . --framework terraform --quiet
   ```

9. **Solução de Problemas**
   - Se encontrar erros de autenticação, verifique suas credenciais AWS
   - Para problemas de estado, use `terraform state` para gerenciar
   - Em caso de conflitos, use `terraform refresh` para atualizar o estado
   - Para problemas de workspace, use `terraform workspace list` para verificar

## Pré-requisitos

1. Configure suas credenciais AWS
2. Configure o Parameter Store com as variáveis necessárias para cada ambiente:

   **Ambiente de Desenvolvimento**:
   ```bash
   aws ssm put-parameter \
     --name "/terraform/vars/dev" \
     --value '{
       "budget_limit": "1000",
       "notification_email": "seu-email@exemplo.com",
       "vpc_cidr": "10.0.0.0/16",
       "cluster_name": "dev-cluster",
       "instance_type": "t3.medium",
       "asg_min_size": "1",
       "asg_max_size": "3",
       "asg_desired_capacity": "2",
       "asg_health_check_grace_period": "300"
     }' \
     --type SecureString
   ```

   **Ambiente de Produção**:
   ```bash
   aws ssm put-parameter \
     --name "/terraform/vars/prod" \
     --value '{
       "budget_limit": "5000",
       "notification_email": "prod-alerts@exemplo.com",
       "vpc_cidr": "10.1.0.0/16",
       "cluster_name": "prod-cluster",
       "instance_type": "t3.large",
       "asg_min_size": "2",
       "asg_max_size": "5",
       "asg_desired_capacity": "3",
       "asg_health_check_grace_period": "300"
     }' \
     --type SecureString
   ```

## Estrutura de Arquivos

```
terraform/
├── modules/
│   ├── monitoring/     # Módulo de monitoramento de custos
│   ├── network/        # Módulo de rede (VPC, subnets)
│   └── ecs/           # Módulo ECS (cluster, ASG)
└── examples/
    └── simple/        # Exemplo de uso do módulo de monitoramento
```

## Variáveis do Módulo de Monitoramento

| Nome | Descrição | Tipo | Padrão |
|------|-----------|------|--------|
| budget_limit | Limite de orçamento mensal em USD | number | 1000 |
| notification_email | Email para notificações de orçamento e anomalias | string | - |

## Variáveis do Módulo de Rede

| Nome | Descrição | Tipo | Padrão |
|------|-----------|------|--------|
| vpc_cidr | Bloco CIDR da VPC | string | "10.0.0.0/16" |

## Variáveis do Módulo ECS

| Nome | Descrição | Tipo | Padrão |
|------|-----------|------|--------|
| vpc_id | ID da VPC onde o cluster será criado | string | - |
| subnet_ids | Lista de IDs das subnets para o ASG | list(string) | - |
| cluster_name | Nome do cluster ECS | string | - |
| instance_type | Tipo de instância para o ASG | string | "t3.medium" |
| asg_min_size | Número mínimo de instâncias no ASG | string | "1" |
| asg_max_size | Número máximo de instâncias no ASG | string | "3" |
| asg_desired_capacity | Capacidade desejada do ASG | string | "2" |
| asg_health_check_grace_period | Período de carência para health check do ASG | string | "300" |

## Observações

- O Parameter Store deve ser configurado antes da primeira execução do Terraform
- As variáveis no Parameter Store devem estar no formato JSON válido
- O parâmetro no Parameter Store deve ser do tipo SecureString para proteger informações sensíveis
- O módulo de rede cria subnets privadas em múltiplas AZs disponíveis
- O módulo ECS configura um cluster Fargate com suporte a Spot para otimização de custos
- Container Insights está habilitado por padrão no cluster ECS
- O módulo de monitoramento configura alertas em 80% e 100% do limite de orçamento 