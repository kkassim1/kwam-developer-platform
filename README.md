# Kwam Developer Platform

A zero-cost, local-first internal developer platform demo. It gives developers a paved road for creating, testing, containerizing, observing, and eventually deploying services without hiding the underlying infrastructure.

> **Status:** Phase 1 — local golden path and CI. AWS deployment is opt-in and disabled by default.

## What this demonstrates

- Platform as a product: a small CLI with a documented developer experience
- Self-service: generate a production-minded Go service in one command
- Golden paths: health checks, metrics, tests, container security, and service metadata by default
- Repeatability: the same checks run locally and in GitHub Actions
- Observability: Prometheus-ready metrics and a local monitoring stack
- Infrastructure as code: an optional, scale-to-zero AWS Lambda path with OpenTofu
- Cost safety: local execution is the default; no workflow automatically creates cloud resources

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
      ▼
Optional OpenTofu plan / manual AWS deployment
```

See [the architecture](docs/architecture.md), [cost controls](docs/cost-safety.md), and [roadmap](docs/roadmap.md).

## Cost model

The normal workflow costs **$0**:

- Go, Docker, Prometheus, and OpenTofu are open source and run locally.
- Standard GitHub-hosted Actions runners are free for public repositories.
- AWS is not required for development or CI.
- Terraform never applies from CI and cloud deployment defaults to disabled.

If you choose to use AWS later, use an AWS Free account plan, configure budgets first, and destroy test resources after demonstrations. No cloud can be guaranteed permanently free, so every cloud step is deliberately manual.

## Repository map

| Path | Purpose |
| --- | --- |
| `cmd/platformctl` | Self-service developer CLI |
| `internal/generator` | Golden-path service generator |
| `templates/go-service` | Opinionated service template |
| `examples/hello-api` | Generated example workload |
| `observability` | Local Prometheus configuration |
| `terraform/aws` | Optional scale-to-zero AWS foundation |
| `.github/workflows` | CI, security, and infrastructure validation |

## Design principles

1. Make the secure path the easiest path.
2. Prefer boring, inspectable building blocks.
3. Keep local development independent of a cloud account.
4. Require an explicit human decision before spending money.
5. Document tradeoffs, rollback, and ownership alongside code.

## License

MIT
