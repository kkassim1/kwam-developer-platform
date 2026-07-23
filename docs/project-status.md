# Project status

Last updated: July 22, 2026

This is the handoff document for the repository. Read it first when resuming work in a new session.

## Current position

Kwam Developer Platform is a working Phase 2 portfolio prototype.

The free local developer path is implemented and has been exercised end to end. The optional AWS reference architecture and its protected GitHub workflow are implemented and statically validated, but no AWS resources have been applied. The project must therefore be described as deployment-ready, not currently hosted or cloud integration-tested.

## What works now

### Developer-facing control plane

- `platformctl doctor` reports CLI and Go runtime information.
- `platformctl new service` creates a new Go HTTP service.
- Service names are validated and unsafe path-like names are rejected.
- Existing target directories are not overwritten.
- Templates are embedded into the CLI binary.

### Generated service contract

Each generated service includes:

- `GET /`
- `GET /healthz`
- `GET /readyz`
- `GET /metrics`
- structured startup and failure logs
- a minimal test entrypoint
- a multi-stage, non-root Distroless container
- Backstage-compatible ownership metadata
- developer-specific run and container instructions

The generated service is an operational foundation. Developers still implement business logic, dependencies, meaningful readiness behavior, business metrics, and application-specific tests.

### Local runtime and observability

- The included `hello-api` builds and runs through Docker Compose.
- Docker reports the reference container as healthy.
- The API responds on port `8080`.
- Prometheus starts on port `9090` and uses the Compose network to scrape `demo-api:8080`.
- The service exposes `http_requests_total`.
- The normal local workflow requires no AWS account.

### Quality and security

- Go tests and vet are configured.
- CI generates and tests a fresh service.
- CI builds the reference container.
- Trivy is configured to reject high and critical fixed vulnerabilities.
- Generated and reference containers run as `nonroot:nonroot`.
- OpenTofu formatting and validation run in CI.

### Optional AWS reference architecture

The disabled-by-default architecture includes:

- encrypted, versioned remote state bootstrap
- repository- and environment-scoped GitHub OIDC trust
- no stored AWS access keys
- AWS Budget notifications
- immutable ECR images tagged with Git commit SHAs
- short ECR and CloudWatch retention
- ECS/Fargate task and service
- Application Load Balancer health checks
- deployment circuit-breaker rollback
- protected manual deploy, rollback, and destroy operations
- service and health URL outputs

Two explicit variables protect the billable path:

```hcl
enable_aws_resources      = false
enable_service_deployment = false
```

No AWS workflow runs on a push or pull request.

## Verification completed

The following checks have been completed locally:

- `make test`
- `make check`
- `make build`
- `platformctl doctor`
- fresh service generation
- generated-service `go test ./...`
- direct generated-service endpoint requests
- reference Docker image build
- Docker Compose startup
- Docker health status
- non-root runtime inspection
- reference API endpoint requests
- Prometheus container startup and UI access
- OpenTofu formatting
- OpenTofu validation for `terraform/aws`
- OpenTofu validation for `terraform/bootstrap`
- `actionlint` for both GitHub workflows
- fresh generated-service container build and non-root image inspection

## Not proven yet

Do not claim these capabilities as completed:

- The AWS stack has not been applied to an AWS account.
- The public AWS URL has not been exercised.
- Cloud rollback and destroy have not been integration-tested.
- Generated standalone repositories do not automatically receive shared CI.
- Generated standalone repositories do not automatically deploy through the AWS workflow.
- The AWS workflow currently deploys the included `examples/hello-api` reference workload.
- Existing applications cannot be inspected or registered by `platformctl`.
- Readiness does not yet model real dependencies such as a database.
- Metrics are intentionally basic.
- HTTPS, application secrets, OpenTelemetry, SLOs, and alert routing are not implemented.
- No Backstage portal is running.
- No multi-team adoption or productivity measurements exist.

## Next work, in priority order

### Priority 0 — preserve and publish the current milestone

1. Review the current working-tree changes.
2. Commit them intentionally.
3. Push a branch and open a pull request.
4. Confirm all GitHub Actions jobs pass in a clean runner.
5. Capture screenshots of service generation, healthy Docker status, and Prometheus for the portfolio.

### Priority 1 — connect generated services to the platform

1. Extract test, vet, container build, vulnerability scan, and artifact metadata into reusable GitHub workflows.
2. Make every generated repository include a small caller workflow.
3. Add contract tests proving the generated caller remains valid.
4. Make the deployment workflow accept a supported generated service rather than hard-coding `examples/hello-api`.
5. Return the deployed URL, image digest, logs link, metrics link, and owner in the workflow summary.

This is the highest-value milestone because it closes the gap between service generation and delivery.

### Priority 2 — onboard existing applications

Add a read-only command such as:

```bash
platformctl validate --path ./existing-app
```

It should report whether the repository satisfies the platform contract:

```text
✓ deterministic tests found
✓ Dockerfile found
✓ container user is non-root
✓ ownership metadata found
✗ /readyz contract missing
✗ metrics contract missing
```

After validation is reliable, add `platformctl register` to generate only the missing metadata and workflow integration without overwriting application code.

### Priority 3 — prove lifecycle and reliability behavior

1. Deploy version A.
2. Attempt a version B with a failing health check.
3. Demonstrate circuit-breaker rollback.
4. Verify version A remains healthy.
5. Record the failure in logs and the workflow summary.
6. Destroy all billable resources.

This can be performed as a short, explicitly approved integration demonstration. It is not required to keep the application hosted continuously.

### Priority 4 — deepen the operational contract

- dependency-aware readiness
- application-specific tests
- useful business and reliability metrics
- OpenTelemetry traces and logs
- SLOs and alerts routed to the owning team
- secrets delivery
- HTTPS and certificate management
- SBOM, provenance, and image signing
- policy-as-code checks
- expiring preview environments

### Priority 5 — expand the platform product

- Go API golden path
- Node/Socket.IO golden path
- static web golden path
- background worker golden path
- optional Backstage interface
- catalog, CI, reliability, ownership, and cost scorecards

Do not add a portal or Kubernetes merely to increase the tool count. Close the self-service developer loop first.

## Portfolio-safe description

Use:

> Kwam Developer Platform is a local-first internal developer platform prototype. Its working Go CLI generates services with standard health, readiness, metrics, logging, tests, secure containers, and ownership metadata. The local Docker and Prometheus path has been tested end to end. A disabled-by-default AWS reference architecture demonstrates OIDC authentication, immutable delivery, ECS/Fargate, health verification, rollback, and cleanup without requiring continuous hosting.

Do not use:

> A production platform currently deploying arbitrary applications at scale.

## Resume checklist

When returning to the repository:

```bash
git status --short
make test
make check
make build
docker compose --profile observe up --build
```

From another terminal:

```bash
curl http://localhost:8080/healthz
curl http://localhost:8080/metrics
docker compose --profile observe ps
```

Clean up:

```bash
make down
```

Do not run `tofu apply` or the manual AWS workflow unless cloud provisioning and possible charges have been explicitly approved.

## Related documentation

- [Developer guide](developer-guide.md)
- [Architecture](architecture.md)
- [Cost safety](cost-safety.md)
- [Interview guide](interview-guide.md)
- [Roadmap](roadmap.md)
- [AWS delivery target](../terraform/aws/README.md)
- [AWS bootstrap](../terraform/bootstrap/README.md)
