output "github_deploy_role_arn" {
  description = "Set this as the AWS_DEPLOY_ROLE_ARN GitHub Actions repository variable."
  value       = aws_iam_role.github_deploy.arn
}

output "state_bucket_name" {
  description = "Set this as the TF_STATE_BUCKET GitHub Actions repository variable."
  value       = aws_s3_bucket.state.id
}
