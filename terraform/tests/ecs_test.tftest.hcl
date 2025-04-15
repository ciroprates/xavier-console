run "test_ecs_cluster" {
  command = plan

  assert {
    condition     = aws_ecs_cluster.fargate_cluster.name == "fargate-spot-cluster"
    error_message = "O nome do cluster ECS deve ser 'fargate-spot-cluster'"
  }

  assert {
    condition     = aws_ssm_parameter.ecs_cluster_name.value == "fargate-spot-cluster"
    error_message = "O valor do parâmetro SSM deve corresponder ao nome do cluster"
  }
}

run "test_ecs_instance_type" {
  command = plan

  assert {
    condition     = aws_ssm_parameter.ecs_instance_type.value == "t4g.nano"
    error_message = "O tipo de instância deve ser 't4g.nano'"
  }
}

run "test_asg_config" {
  command = plan

  assert {
    condition     = aws_autoscaling_group.ecs_asg.min_size == 1
    error_message = "O tamanho mínimo do ASG deve ser 1"
  }

  assert {
    condition     = aws_autoscaling_group.ecs_asg.max_size == 10
    error_message = "O tamanho máximo do ASG deve ser 10"
  }

  assert {
    condition     = aws_autoscaling_group.ecs_asg.desired_capacity == 1
    error_message = "A capacidade desejada do ASG deve ser 1"
  }
}

run "test_budget" {
  command = plan

  assert {
    condition     = aws_budgets_budget.monthly.name == "monthly-budget"
    error_message = "O nome do budget deve ser 'monthly-budget'"
  }

  assert {
    condition     = aws_budgets_budget.monthly.limit_amount == "10"
    error_message = "O limite do budget deve ser 10"
  }
}

run "test_anomaly_monitor" {
  command = plan

  assert {
    condition     = aws_ce_anomaly_monitor.anomaly_monitor.name == "cost-anomaly-monitor"
    error_message = "O nome do monitor de anomalias deve ser 'cost-anomaly-monitor'"
  }
} 