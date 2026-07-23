output "aws_resources_enabled" {
  description = "Confirms whether the cost-bearing AWS path is enabled."
  value       = var.enable_aws_resources
}

output "service_deployment_enabled" {
  description = "Confirms whether the billable workload path is enabled."
  value       = var.enable_aws_resources && var.enable_service_deployment
}

output "ecr_repository_url" {
  description = "Repository URL when the optional AWS foundation is enabled."
  value       = try(aws_ecr_repository.services[0].repository_url, null)
}

output "service_url" {
  description = "Public HTTP URL when the optional ECS service is enabled."
  value       = try("http://${aws_lb.service[0].dns_name}", null)
}

output "health_url" {
  description = "Health endpoint used by deployment verification."
  value       = try("http://${aws_lb.service[0].dns_name}/healthz", null)
}
