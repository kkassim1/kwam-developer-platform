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
