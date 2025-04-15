package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestECSInfrastructure(t *testing.T) {
	t.Parallel()

	// Configuração do teste
	awsRegion := "us-east-1"
	terraformOptions := &terraform.Options{
		TerraformDir: "../..",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	// Garantir que os recursos sejam destruídos após o teste
	defer terraform.Destroy(t, terraformOptions)

	// Inicializar e aplicar a configuração
	terraform.InitAndApply(t, terraformOptions)

	// Obter os outputs do Terraform
	clusterName := terraform.Output(t, terraformOptions, "ecs_cluster_name")
	instanceType := terraform.Output(t, terraformOptions, "ecs_instance_type")

	// Teste 1: Verificar se o cluster ECS foi criado
	t.Run("TestECSCluster", func(t *testing.T) {
		cluster := aws.GetEcsCluster(t, awsRegion, clusterName)
		assert.NotNil(t, cluster, "O cluster ECS deve existir")
		assert.Equal(t, "ACTIVE", *cluster.Status, "O cluster deve estar ativo")
	})

	// Teste 2: Verificar se os parâmetros SSM foram criados
	t.Run("TestSSMParameters", func(t *testing.T) {
		// Verificar parâmetro do tipo de instância
		instanceTypeParam := aws.GetSsmParameter(t, awsRegion, "/ecs/instance/type")
		assert.Equal(t, instanceType, instanceTypeParam, "O tipo de instância deve corresponder")

		// Verificar parâmetro do nome do cluster
		clusterNameParam := aws.GetSsmParameter(t, awsRegion, "/ecs/cluster/name")
		assert.Equal(t, clusterName, clusterNameParam, "O nome do cluster deve corresponder")
	})

	// Teste 3: Verificar se o Auto Scaling Group foi criado
	t.Run("TestAutoScalingGroup", func(t *testing.T) {
		asgName := "ecs-fargate-spot-asg"
		asg := aws.GetAsg(t, awsRegion, asgName)
		assert.NotNil(t, asg, "O Auto Scaling Group deve existir")
		assert.Equal(t, int64(1), *asg.MinSize, "O tamanho mínimo deve ser 1")
		assert.Equal(t, int64(10), *asg.MaxSize, "O tamanho máximo deve ser 10")
	})

	// Teste 4: Verificar se o budget foi configurado
	t.Run("TestBudget", func(t *testing.T) {
		budgets := aws.GetBudgets(t, awsRegion)
		found := false
		for _, budget := range budgets {
			if *budget.BudgetName == "monthly-budget" {
				found = true
				assert.Equal(t, "ACTIVE", *budget.BudgetState, "O budget deve estar ativo")
				break
			}
		}
		assert.True(t, found, "O budget mensal deve existir")
	})

	// Teste 5: Verificar se o monitor de anomalias foi configurado
	t.Run("TestAnomalyMonitor", func(t *testing.T) {
		monitors := aws.GetCostAnomalyMonitors(t, awsRegion)
		found := false
		for _, monitor := range monitors {
			if *monitor.MonitorName == "cost-anomaly-monitor" {
				found = true
				assert.Equal(t, "ACTIVE", *monitor.MonitorState, "O monitor deve estar ativo")
				break
			}
		}
		assert.True(t, found, "O monitor de anomalias deve existir")
	})
} 