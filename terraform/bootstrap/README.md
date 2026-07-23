# One-time deployment bootstrap

This module creates the two prerequisites that cannot be created by the deployment workflow itself:

- an encrypted, versioned, private S3 bucket for OpenTofu state
- a GitHub OIDC provider and repository-scoped deployment role

Running `tofu init` and `tofu plan` is free. Applying this module creates an S3 bucket, which can incur a very small storage/request charge. Nothing applies automatically.

```bash
tofu init
tofu plan \
  -var='github_owner=YOUR_GITHUB_USER' \
  -var='state_bucket_name=GLOBALLY_UNIQUE_BUCKET_NAME'
```

If you explicitly choose to apply it, copy the two outputs into GitHub repository variables named `AWS_DEPLOY_ROLE_ARN` and `TF_STATE_BUCKET`. Also create:

- repository variable `AWS_REGION` (for example `us-east-1`)
- repository secret `BUDGET_EMAIL`
- GitHub environment `portfolio-aws` with required reviewers and a `main`-branch deployment rule

The OIDC trust policy only accepts tokens for that protected environment in this repository. No long-lived AWS access key is stored in GitHub.
