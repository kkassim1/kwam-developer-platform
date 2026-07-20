# Interview guide

## Thirty-second explanation

> Kwam Developer Platform is a local-first internal developer platform prototype. A developer uses `platformctl` to generate a production-minded Go service with health checks, metrics, tests, a secure container, and ownership metadata already included. GitHub Actions applies the same test, infrastructure, and vulnerability gates to every change. Cloud provisioning is optional and manually approved, so the developer workflow is free while the AWS foundation still demonstrates OpenTofu, budgets, immutable registries, log retention, and cost ownership.

## Is it real or an example?

It is a working phase-one platform prototype:

- The CLI genuinely creates new services.
- Generated services compile, test, run, and expose operational endpoints.
- Docker Compose genuinely runs the example workload and Prometheus locally.
- GitHub Actions genuinely builds and security-scans the container.
- OpenTofu genuinely validates and can provision the optional AWS foundation when explicitly enabled.

It is not yet a production, multi-tenant platform:

- It does not deploy arbitrary workloads to AWS yet.
- It has no Backstage portal UI yet.
- It does not yet federate GitHub to AWS with OIDC.
- It does not yet automate image promotion or rollback.
- It currently provides one golden path: a Go HTTP service.

That boundary is intentional. The project demonstrates an iterative platform-product approach rather than pretending a first release solves every workload.

## What happens when a developer uses it?

1. The developer runs `platformctl new service` with a name and owner.
2. The CLI validates the name to prevent unsafe paths and inconsistent service naming.
3. The generator copies its embedded template and replaces service and ownership placeholders.
4. The output includes runnable code, tests, a Dockerfile, README, and Backstage-compatible catalog metadata.
5. The service exposes `/healthz`, `/readyz`, and `/metrics`, creating one operational contract across teams.
6. Pull requests run formatting, tests, vet, image building, vulnerability scanning, and OpenTofu validation.
7. Local Compose runs the workload with Prometheus without requiring a cloud account.
8. The optional AWS foundation remains disabled unless a human provides an email and explicitly enables it.

## Why these design decisions?

### Go CLI with no third-party dependencies

The CLI is fast to compile, easy to distribute as one binary, and has a small software-supply-chain surface. The tradeoff is fewer features than a mature CLI framework.

### Embedded template

Embedding the golden path inside the CLI makes a release reproducible: the binary and its template version travel together. The tradeoff is that changing templates requires releasing the CLI.

### Health, readiness, and metrics by default

These endpoints make services operable without asking every team to invent a different convention. Health answers whether the process works; readiness answers whether it should receive traffic; metrics support monitoring and SLOs.

### Docker Compose before Kubernetes

Compose keeps the first developer experience free and understandable. Kubernetes would add orchestration evidence but also cognitive load before the service contract and workflow were proven.

### Backstage metadata without running Backstage

The project preserves a path to a service catalog without forcing developers to run a heavy portal locally. Backstage becomes a later user interface, not a prerequisite for phase one.

### OpenTofu

OpenTofu expresses resources declaratively and produces reviewable plans while using familiar Terraform concepts and AWS provider resources.

### Cloud disabled by default

`enable_aws_resources=false` makes accidental provisioning impossible in the normal path. CI has no AWS credentials and performs validation only. This favors cost safety over fully automated deployment in the first release.

### Budget first

When cloud resources are enabled, a valid notification email and small budget are required. A budget does not stop all charges, but it creates ownership and early feedback.

### Immutable containers and non-root runtime

Immutable artifacts make rollback and audit trails reliable. Non-root execution reduces the effect of a compromise. Trivy blocks known high or critical vulnerabilities instead of producing an optional report.

### Short log and image retention

Short retention limits idle storage cost in a learning environment. Production retention would be chosen from compliance, troubleshooting, and recovery requirements.

## Code map

| Code | Responsibility |
| --- | --- |
| `cmd/platformctl/main.go` | Parses commands and presents the developer-facing platform interface |
| `internal/generator/generator.go` | Validates requests, walks the embedded template, replaces variables, and writes services |
| `internal/generator/generator_test.go` | Proves valid generation and rejects unsafe path-like names |
| `internal/generator/template` | Defines the approved Go service golden path |
| `examples/hello-api` | Proves the workload contract |
| `compose.yaml` | Provides the free local runtime and observability network |
| `observability/prometheus.yml` | Scrapes the standard service metrics endpoint |
| `.github/workflows/ci.yml` | Enforces tests, generated-service validation, container security, and IaC validation |
| `terraform/aws` | Defines the opt-in AWS budget, ECR registry, log group, and ECS cluster |

## Can existing applications use it?

Yes, after adapters are added. Existing applications do not have to be rewritten in Go. They need to implement the platform contract:

- a Dockerfile with a non-root runtime
- health and readiness endpoints
- metrics or telemetry
- ownership and catalog metadata
- deterministic tests
- CI that calls shared platform gates
- deployment configuration matching a supported workload type

Simon Says Assassin needs separate paths for its static Three.js client and stateful Socket.IO server. DebateApp needs paths for its React frontend, Go API, MongoDB dependency, WebSocket traffic, and uploaded media. These differences are why a platform needs multiple golden paths rather than one universal template.

## Next implementation sequence

1. Extract CI jobs into reusable workflows that private application repositories can call.
2. Add Node/Socket.IO, Go API, and static-web templates.
3. Add `platformctl register` for repositories that were not generated by the platform.
4. Add GitHub-to-AWS OIDC so deployments use short-lived credentials rather than stored keys.
5. Build and publish immutable images to ECR.
6. Add one low-cost workload deployment target and automated smoke tests.
7. Add environment promotion and rollback by image digest.
8. Add OpenTelemetry and reliability dashboards.
9. Add Backstage as an optional portal over the same CLI, templates, and metadata.
10. Onboard sanitized versions of Simon Says Assassin and DebateApp as reference workloads.

## Honest answers to likely questions

**Why not Kubernetes immediately?**  
The first risk was whether the developer contract and golden path were useful, not whether I could create a cluster. Compose made that experiment fast and free. Kubernetes fits after multiple services need scheduling, policy, and shared cluster operations.

**Does an AWS Budget prevent charges?**  
No. It alerts on actual or forecast spend. Stronger controls include disabled-by-default resources, no cloud credentials in CI, manual apply, short retention, cleanup, and current pricing reviews.

**Is Backstage the platform?**  
No. Backstage can become one interface. The platform is the combined product: templates, APIs and CLI, delivery workflows, infrastructure, policies, documentation, and support model.

**What makes this platform engineering instead of DevOps scripts?**  
It is an owned product for developers with a user interface, versioned contract, repeatable golden paths, guardrails, documentation, cost ownership, success measures, and an adoption roadmap.
