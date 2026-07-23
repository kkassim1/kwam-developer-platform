locals {
  foundation_count = var.enable_aws_resources ? 1 : 0
  service_count    = var.enable_aws_resources && var.enable_service_deployment ? 1 : 0

  common_tags = {
    Project   = "kwam-developer-platform"
    ManagedBy = "opentofu"
    Owner     = "kkassim1"
    CostClass = "portfolio-learning"
  }
}

resource "aws_budgets_budget" "learning" {
  count = local.foundation_count

  name         = "kwam-platform-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 50
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.budget_email]
  }

  lifecycle {
    precondition {
      condition     = can(regex("^[^@]+@[^@]+$", var.budget_email))
      error_message = "Set a valid budget_email before enabling AWS resources."
    }
  }
}

resource "aws_ecr_repository" "services" {
  count = local.foundation_count

  name                 = "kwam-platform-services"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_lifecycle_policy" "services" {
  count      = local.foundation_count
  repository = aws_ecr_repository.services[0].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Remove old untagged images"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 7
      }
      action = { type = "expire" }
    }]
  })
}

resource "aws_cloudwatch_log_group" "platform" {
  count             = local.foundation_count
  name              = "/portfolio/kwam-developer-platform"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "platform" {
  count = local.foundation_count
  name  = "kwam-developer-platform"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }
}
