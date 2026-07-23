variable "aws_region" {
  description = "AWS region used only when resources are explicitly enabled."
  type        = string
  default     = "us-east-1"
}

variable "enable_aws_resources" {
  description = "Cost-safety switch. No AWS resources are created unless this is true."
  type        = bool
  default     = false
}

variable "enable_service_deployment" {
  description = "Second safety switch. Creates the network, load balancer, task, and running ECS service only when the foundation is also enabled."
  type        = bool
  default     = false
}

variable "enable_container_insights" {
  description = "Enables billable ECS Container Insights only after an explicit decision."
  type        = bool
  default     = false
}

variable "container_image" {
  description = "Immutable container image URI to deploy, normally the ECR repository URL plus a Git commit SHA."
  type        = string
  default     = ""
}

variable "service_name" {
  description = "Name used for the ECS task, service, and load-balancing resources."
  type        = string
  default     = "hello-api"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,38}[a-z0-9]$", var.service_name))
    error_message = "service_name must be 3-40 lowercase letters, numbers, or hyphens."
  }
}

variable "container_port" {
  description = "Port exposed by the generated golden-path service."
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Number of Fargate tasks. Keep at one for the portfolio environment."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 1 && var.desired_count <= 2
    error_message = "The portfolio environment supports one or two tasks."
  }
}

variable "monthly_budget_usd" {
  description = "Monthly cost budget for the learning environment."
  type        = number
  default     = 5

  validation {
    condition     = var.monthly_budget_usd > 0 && var.monthly_budget_usd <= 20
    error_message = "The portfolio environment budget must stay between $1 and $20."
  }
}

variable "budget_email" {
  description = "Email for AWS budget notifications. Required when resources are enabled."
  type        = string
  default     = ""
}
