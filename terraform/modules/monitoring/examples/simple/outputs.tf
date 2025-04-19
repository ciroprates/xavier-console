output "budget_id" {
  description = "The ID of the created budget"
  value       = module.monitoring.budget_id
}

output "budget_name" {
  description = "The name of the created budget"
  value       = module.monitoring.budget_name
}

output "anomaly_detector_id" {
  description = "ID do detector de anomalias"
  value       = module.monitoring.anomaly_detector_id
} 