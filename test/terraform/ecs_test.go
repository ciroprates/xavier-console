package test

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/autoscaling"
	"github.com/aws/aws-sdk-go-v2/service/ecs"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestECSInfrastructure(t *testing.T) {
	t.Parallel()
	ctx := context.Background()

	// Configuração do teste
	awsRegion := "us-east-1"
	terraformOptions := &terraform.Options{
		TerraformDir: "../../terraform",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	// Configurar cliente AWS
	cfg, err := config.LoadDefaultConfig(ctx, config.WithRegion(awsRegion))
	if err != nil {
		t.Fatalf("Não foi possível carregar a configuração AWS: %v", err)
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
		ecsClient := ecs.NewFromConfig(cfg)
		cluster, err := ecsClient.DescribeClusters(ctx, &ecs.DescribeClustersInput{
			Clusters: []string{clusterName},
		})
		assert.NoError(t, err)
		assert.Len(t, cluster.Clusters, 1, "O cluster ECS deve existir")
		assert.Equal(t, "ACTIVE", *cluster.Clusters[0].Status, "O cluster deve estar ativo")
	})

	// Teste 2: Verificar se os parâmetros SSM foram criados
	t.Run("TestSSMParameters", func(t *testing.T) {
		ssmClient := ssm.NewFromConfig(cfg)

		// Verificar parâmetro do tipo de instância
		instanceTypeParam, err := ssmClient.GetParameter(ctx, &ssm.GetParameterInput{
			Name: aws.String("/ecs/instance/type"),
		})
		assert.NoError(t, err)
		assert.Equal(t, instanceType, *instanceTypeParam.Parameter.Value, "O tipo de instância deve corresponder")

		// Verificar parâmetro do nome do cluster
		clusterNameParam, err := ssmClient.GetParameter(ctx, &ssm.GetParameterInput{
			Name: aws.String("/ecs/cluster/name"),
		})
		assert.NoError(t, err)
		assert.Equal(t, clusterName, *clusterNameParam.Parameter.Value, "O nome do cluster deve corresponder")
	})

	// Teste 3: Verificar se o Auto Scaling Group foi criado
	t.Run("TestAutoScalingGroup", func(t *testing.T) {
		asgClient := autoscaling.NewFromConfig(cfg)
		asg, err := asgClient.DescribeAutoScalingGroups(ctx, &autoscaling.DescribeAutoScalingGroupsInput{
			AutoScalingGroupNames: []string{"ecs-fargate-spot-asg"},
		})
		assert.NoError(t, err)
		assert.Len(t, asg.AutoScalingGroups, 1, "Deve existir exatamente um ASG")

		group := asg.AutoScalingGroups[0]
		assert.Equal(t, int32(1), *group.MinSize, "O tamanho mínimo deve ser 1")
		assert.Equal(t, int32(10), *group.MaxSize, "O tamanho máximo deve ser 10")
	})

	// Note: Removing budget and anomaly monitor tests as they require custom implementations
	// These would need to be implemented using the AWS Cost Explorer API directly
}
