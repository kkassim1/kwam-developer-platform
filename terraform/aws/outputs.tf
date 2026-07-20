output "aws_resources_enabled" {
  description = "Confirms whether the cost-bearing AWS path is enabled."
  value       = var.enable_aws_resources
}

output "ecr_repository_url" {
  description = "Repository URL when the optional AWS foundation is enabled."
  value       = try(aws_ecr_repository.services[0].repository_url, null)
}
