# Optional AWS foundation

This module is intentionally disabled by default. A normal `tofu plan` creates no resources.

```bash
tofu init
tofu plan
```

Only after reviewing current AWS pricing and configuring an AWS Budget:

```bash
tofu plan \
  -var='enable_aws_resources=true' \
  -var='budget_email=you@example.com'
```

Do not apply from CI. If you manually apply for a demonstration, destroy the environment afterward and verify the AWS console is empty.
