resource "aws_lb" "service" {
  count = local.service_count

  name               = "kwam-platform-service"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer[0].id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "service" {
  count = local.service_count

  name        = "kwam-platform-service"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.platform[0].id

  health_check {
    enabled             = true
    path                = "/healthz"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 15
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http" {
  count = local.service_count

  load_balancer_arn = aws_lb.service[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service[0].arn
  }
}

resource "aws_ecs_task_definition" "service" {
  count = local.service_count

  family                   = "kwam-platform-${var.service_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.execution[0].arn
  task_role_arn            = aws_iam_role.task[0].arn

  container_definitions = jsonencode([{
    name      = var.service_name
    image     = var.container_image
    essential = true
    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
      protocol      = "tcp"
    }]
    healthCheck = {
      command     = ["CMD", "/service", "-healthcheck"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.platform[0].name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = var.service_name
      }
    }
  }])

  lifecycle {
    precondition {
      condition     = !var.enable_service_deployment || can(regex("^[^:]+\\.dkr\\.ecr\\.[^:]+\\.amazonaws\\.com/.+:[a-f0-9]{7,64}$", var.container_image))
      error_message = "container_image must be an ECR image tagged with an immutable Git SHA."
    }
  }
}

resource "aws_ecs_service" "service" {
  count = local.service_count

  name                               = var.service_name
  cluster                            = aws_ecs_cluster.platform[0].id
  task_definition                    = aws_ecs_task_definition.service[0].arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  wait_for_steady_state              = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.service[0].id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.service[0].arn
    container_name   = var.service_name
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]
}
