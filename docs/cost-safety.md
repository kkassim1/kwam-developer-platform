# Cost safety

The project is designed to be useful without a cloud account.

## Free default path

- Build and test with the local Go toolchain.
- Run workloads in local Docker Compose.
- Collect local metrics with Prometheus.
- Validate infrastructure syntax without applying it.
- Use standard GitHub-hosted runners in this public repository.
- Read, build, test, and demonstrate the complete deployment design without creating an AWS account.

## Cloud guardrails

1. `enable_aws_resources` and `enable_service_deployment` both default to `false`.
2. Pull-request CI runs formatting and validation only; it has no AWS credentials.
3. The cloud workflow only runs through `workflow_dispatch`, exact-text confirmation, and the protected `portfolio-aws` environment.
4. GitHub receives short-lived, repository-scoped OIDC credentials rather than stored AWS keys.
5. The foundation creates a monthly budget before workload resources are introduced.
6. Container Insights has its own disabled-by-default switch.
7. Container retention removes older untagged images and full teardown removes the private repository and its images.
8. CloudWatch retention is seven days.
9. The design avoids a NAT Gateway. It uses public subnets for this short-lived learning environment.
10. Deployments are serialized so two workflows cannot change the same state concurrently.

## What becomes billable if applied

The design is free to build and validate, not guaranteed free to host. Applying the bootstrap creates an S3 state bucket. Applying the foundation can create ECR and CloudWatch storage. Enabling the service creates Fargate compute, an Application Load Balancer, and public IPv4 addresses. The AWS Budget is an alert, not a hard spending limit.

## Before any AWS demonstration

- Use the AWS Free account plan when eligible.
- Enable MFA on the root user and use a scoped deployment role.
- Confirm billing contacts and alerts.
- Run `tofu plan` and review every resource.
- Record the start time and expected maximum spend.
- Run `tofu destroy` after the demonstration and confirm no resources remain.
- Remember that the bootstrap state bucket intentionally remains after the service destroy; delete it separately only after preserving or no longer needing its state.

No AWS service should be described as permanently free. Pricing and free-tier rules change, so check the current AWS pricing pages before every deployment.
