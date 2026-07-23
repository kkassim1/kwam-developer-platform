variable "aws_region" {
  description = "AWS region used by the deployment workflow."
  type        = string
  default     = "us-east-1"
}

variable "github_owner" {
  description = "GitHub user or organization that owns the repository."
  type        = string
}

variable "github_repository" {
  description = "Repository name without the owner."
  type        = string
  default     = "kwam-developer-platform"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for encrypted OpenTofu state."
  type        = string
}
