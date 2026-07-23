# Optional AWS delivery target

This module describes a complete ECR-to-ECS/Fargate deployment for the included reference workload, but both cost-bearing switches are disabled by default. Reading, formatting, and validating it creates no resources:

```bash
tofu init -backend=false
tofu fmt -check
tofu validate
```

The manual GitHub workflow implements three operations:

- `deploy`: creates the foundation, publishes an immutable Git-SHA image, deploys it, verifies `/healthz`, and returns the URL
- `rollback`: redeploys an existing immutable image tag
- `destroy`: removes the AWS foundation and workload; the separate bootstrap state bucket remains

No workflow runs from a push or pull request. The job requires the `portfolio-aws` environment, OIDC role, exact confirmation, and a manual dispatch.

With valid AWS credentials, a review-only plan can explicitly demonstrate what would be created without applying it:

```bash
tofu plan \
  -var='enable_aws_resources=true' \
  -var='enable_service_deployment=true' \
  -var='container_image=123456789012.dkr.ecr.us-east-1.amazonaws.com/kwam-platform-services:abcdef0' \
  -var='budget_email=you@example.com'
```

That plan is not applied automatically. If you choose to run the protected deployment, review current AWS pricing first and use the `destroy` action immediately after the demonstration.
