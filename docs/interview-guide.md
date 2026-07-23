# Interview guide

## Thirty-second explanation

> Kwam Developer Platform is a local-first internal developer platform prototype. A developer uses `platformctl` to generate a production-minded Go service with health checks, metrics, tests, a secure container, and ownership metadata already included. GitHub Actions applies consistent quality and security gates. A separate protected workflow demonstrates the complete delivery loop for the included reference workload—OIDC authentication, immutable ECR publishing, ECS/Fargate deployment, health verification, URL discovery, rollback, and cleanup—while both cloud switches remain disabled by default. The entire platform can therefore be built, tested, and reviewed without paying to host it.

## Is it real or an example?

It is a working phase-one platform prototype:

- The CLI genuinely creates new services.
- Generated services compile, test, run, and expose operational endpoints.
- Docker Compose genuinely runs the example workload and Prometheus locally.
- GitHub Actions genuinely builds and security-scans the container.
- OpenTofu genuinely validates and describes the optional network, registry, identity, load balancer, Fargate service, logging, and budget resources.
- The manual workflow genuinely implements deploy, health verification, rollback to an immutable image, and destroy operations.

It is not yet a production, multi-tenant platform:

- It has no Backstage portal UI yet.
- It currently provides one golden path: a Go HTTP service.
- Its AWS target is a portfolio reference architecture, not a currently hosted production environment.
- Generated standalone repositories do not consume the AWS workflow automatically yet; reusable workflows and `platformctl register` remain onboarding work.
- It still needs HTTPS, secret delivery, production telemetry, policy as code, and additional workload types.

That boundary is intentional. The project demonstrates an iterative platform-product approach rather than pretending a first release solves every workload.

## What happens when a developer uses it?

1. The developer runs `platformctl new service` with a name and owner.
2. The CLI validates the name to prevent unsafe paths and inconsistent service naming.
3. The generator copies its embedded template and replaces service and ownership placeholders.
4. The output includes runnable code, tests, a Dockerfile, README, and Backstage-compatible catalog metadata.
5. The service exposes `/healthz`, `/readyz`, and `/metrics`, creating one operational contract across teams.
6. Pull requests run formatting, tests, vet, image building, vulnerability scanning, and OpenTofu validation.
7. Local Compose runs the workload with Prometheus without requiring a cloud account.
8. The optional AWS workflow requires protected-environment approval and exchanges GitHub identity for short-lived AWS credentials.
9. Deployment creates the budget and ECR foundation first, publishes a Git-SHA image, and then enables the Fargate workload.
10. The workflow waits for ECS health, verifies `/healthz`, returns the URL, and supports rollback or full workload teardown.

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

### Cloud disabled by default and manually promoted

`enable_aws_resources=false` and `enable_service_deployment=false` make accidental provisioning impossible in the normal path. Pull-request CI has no AWS credentials. The separate deployment workflow requires manual dispatch, exact confirmation, a protected GitHub environment, and repository-scoped OIDC trust.

### ECS/Fargate instead of Kubernetes

The cloud target demonstrates container scheduling, immutable task definitions, load-balancer health checks, rolling deployment, and circuit-breaker rollback without introducing cluster management. The tradeoff is that Fargate, public IPv4 addresses, and the load balancer cost money whenever the optional stack is applied.

### Public subnets without a NAT Gateway

For this temporary learning environment, tasks receive public IPs so they can pull from ECR and send logs without a NAT Gateway's fixed hourly cost. Security groups still allow inbound application traffic only from the load balancer. A production architecture would reconsider private subnets, VPC endpoints, HTTPS, WAF, and egress controls based on its threat model and budget.

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
| `.github/workflows/aws-service.yml` | Performs protected deploy, rollback, health verification, URL publication, and destroy |
| `terraform/bootstrap` | Defines encrypted state and repository/environment-scoped GitHub OIDC trust |
| `terraform/aws` | Defines the opt-in budget, ECR, ECS/Fargate, IAM, networking, load balancer, and logs |

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
4. Add HTTPS, secret delivery, and preview-environment expiration to the AWS target.
5. Add OpenTelemetry and reliability dashboards.
6. Add policy-as-code checks to complement the existing cost switches and IAM boundaries.
7. Add Backstage as an optional portal over the same CLI, templates, and metadata.
8. Onboard sanitized versions of Simon Says Assassin and DebateApp as reference workloads.

## Honest answers to likely questions

**Why not Kubernetes immediately?**  
The first risk was whether the developer contract and golden path were useful, not whether I could create a cluster. Compose made that experiment fast and free. Kubernetes fits after multiple services need scheduling, policy, and shared cluster operations.

**Does an AWS Budget prevent charges?**  
No. It alerts on actual or forecast spend. Stronger controls include disabled-by-default resources, no cloud credentials in pull-request CI, protected manual promotion, short retention, cleanup, and current pricing reviews.

**Can you prove the cloud workflow without paying AWS?**

I can prove the design through source review, OpenTofu formatting and validation, workflow inspection, local service tests, container builds, and generated-service contract tests. I describe it as deployment-ready rather than claiming it is currently hosted. A real apply is the integration test and would be billable, so it remains an explicit demonstration decision.

**Is Backstage the platform?**  
No. Backstage can become one interface. The platform is the combined product: templates, APIs and CLI, delivery workflows, infrastructure, policies, documentation, and support model.

**What makes this platform engineering instead of DevOps scripts?**  
It is an owned product for developers with a user interface, versioned contract, repeatable golden paths, guardrails, documentation, cost ownership, success measures, and an adoption roadmap.
