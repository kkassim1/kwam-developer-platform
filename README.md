# Kwam Developer Platform

A zero-cost, local-first internal developer platform demo. It gives developers a paved road for creating, testing, containerizing, observing, and optionally deploying services without hiding the underlying infrastructure.

> **Status:** Phase 2 prototype — the local golden path works and an end-to-end AWS delivery path is implemented for the included reference workload. It is opt-in and disabled by default. No cloud resources are required.

See [project status](docs/project-status.md) for what is currently working, what has been verified, current limitations, and the prioritized next milestones.

## What this demonstrates

- Platform as a product: a small CLI with a documented developer experience
- Self-service: generate a production-minded Go service in one command
- Golden paths: health checks, metrics, tests, container security, and service metadata by default
- Repeatability: the same checks run locally and in GitHub Actions
- Observability: Prometheus-ready metrics and a local monitoring stack
- Infrastructure as code: an optional ECS/Fargate delivery target with OpenTofu
- Secure delivery: GitHub OIDC, protected environments, immutable images, health verification, and rollback
- Cost safety: local execution is the default; only a manually dispatched and confirmed workflow can create cloud resources

## Quick start

Requirements: Go 1.25+ and Docker with Compose.

```bash
make test
make build
./bin/platformctl doctor
./bin/platformctl new service --name orders-api --owner platform-team --output ./sandbox
```

Run the included example service:

```bash
make demo
curl http://localhost:8080/healthz
curl http://localhost:8080/metrics
```

Start the free local observability stack:

```bash
make observe
```

- Demo API: http://localhost:8080
- Prometheus: http://localhost:9090

Stop everything with `make down`.

## Using the platform as a developer

Read the [developer guide](docs/developer-guide.md) for:

- the problem the platform solves
- what a generated service contains
- exactly what local tests prove
- the workflow for building a new service
- how to align an existing application with the platform contract
- the boundary between local containers and real cloud deployment
- common troubleshooting steps

## Developer experience

```text
Developer request
      │
      ▼
platformctl new service
      │
      ├── runnable Go API
      ├── health and readiness endpoints
      ├── Prometheus metrics
      ├── unit tests
      ├── non-root multi-stage container
      └── catalog metadata
      │
      ▼
GitHub Actions quality and security gates
      │
      ├── free path: local Docker + Prometheus
      │
      └── optional protected deployment
              ├── short-lived GitHub OIDC credentials
              ├── immutable image in ECR
              ├── ECS/Fargate + load balancer
              ├── health verification + public URL
              └── rollback or explicit destroy
```

See [project status](docs/project-status.md), [the developer guide](docs/developer-guide.md), [architecture](docs/architecture.md), [cost controls](docs/cost-safety.md), [interview guide](docs/interview-guide.md), and [roadmap](docs/roadmap.md).

## Cost model

The normal workflow costs **$0**:

- Go, Docker, Prometheus, and OpenTofu are open source and run locally.
- Standard GitHub-hosted Actions runners are free for public repositories.
- AWS is not required for development or CI.
- Normal CI only tests and validates. Both cloud feature switches default to disabled.
- Building, reviewing, and validating the deployment code creates no AWS resources.

If you choose to use AWS later, use an AWS Free account plan, configure budgets first, and destroy test resources after demonstrations. No cloud can be guaranteed permanently free, so every cloud step is deliberately manual.

## Repository map

| Path | Purpose |
| --- | --- |
| `cmd/platformctl` | Self-service developer CLI |
| `internal/generator` | Golden-path service generator |
| `internal/generator/template` | Embedded, opinionated service template |
| `examples/hello-api` | Generated example workload |
| `observability` | Local Prometheus configuration |
| `docs/project-status.md` | Current capabilities, verified evidence, limitations, and prioritized next work |
| `docs/developer-guide.md` | New-service workflow, existing-app onboarding, testing, and troubleshooting |
| `terraform/bootstrap` | One-time encrypted state and repository-scoped GitHub OIDC role |
| `terraform/aws` | Optional ECR, ECS/Fargate, networking, load balancer, logs, and budget |
| `.github/workflows` | CI plus protected manual deploy, rollback, and destroy operations |

## Design principles

1. Make the secure path the easiest path.
2. Prefer boring, inspectable building blocks.
3. Keep local development independent of a cloud account.
4. Require an explicit human decision before spending money.
5. Document tradeoffs, rollback, and ownership alongside code.

## License

MIT
