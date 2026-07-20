# Cost safety

The project is designed to be useful without a cloud account.

## Free default path

- Build and test with the local Go toolchain.
- Run workloads in local Docker Compose.
- Collect local metrics with Prometheus.
- Validate infrastructure syntax without applying it.
- Use standard GitHub-hosted runners in this public repository.

## Cloud guardrails

1. `enable_aws_resources` defaults to `false`.
2. CI runs formatting and validation only; it has no AWS credentials.
3. No Terraform workflow contains an automatic apply step.
4. The optional AWS foundation creates a monthly budget before workload resources are introduced.
5. Container retention removes older untagged images.
6. CloudWatch retention is seven days.
7. The design avoids NAT Gateway and load-balancer resources in the learning environment because they create fixed hourly costs.

## Before any AWS demonstration

- Use the AWS Free account plan when eligible.
- Enable MFA on the root user and use a scoped deployment role.
- Confirm billing contacts and alerts.
- Run `tofu plan` and review every resource.
- Record the start time and expected maximum spend.
- Run `tofu destroy` after the demonstration and confirm no resources remain.

No AWS service should be described as permanently free. Pricing and free-tier rules change, so check the current AWS pricing pages before every deployment.
