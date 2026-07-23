# Developer guide

This guide explains what Kwam Developer Platform does for an application developer, what you can test locally, and what is not automated yet.

## What problem does this solve?

Starting a service is easy. Starting it consistently is harder.

Without a platform, each team may make different decisions about:

- project structure
- health checks
- readiness checks
- metrics
- logging
- tests
- container security
- service ownership
- CI requirements
- deployment conventions

Those differences create repeated setup work for developers and repeated support work for platform engineers.

Kwam Developer Platform provides a golden path: one approved starting point that includes these operational requirements by default. Developers keep control of the generated code and concentrate on application behavior rather than rebuilding the same plumbing.

## What do developers receive?

Running:

```bash
platformctl new service \
  --name orders-api \
  --owner checkout-team \
  --output ./services
```

creates:

```text
services/orders-api/
├── main.go             runnable Go HTTP service
├── main_test.go        test entrypoint
├── go.mod              Go module definition
├── Dockerfile          non-root multi-stage image
├── catalog-info.yaml   service ownership metadata
└── README.md           service-specific instructions
```

Every generated service implements the platform contract:

| Contract | Purpose |
| --- | --- |
| `GET /` | Application response |
| `GET /healthz` | Confirms that the process is alive |
| `GET /readyz` | Confirms that the service can receive traffic |
| `GET /metrics` | Exposes Prometheus-format metrics |
| Structured logs | Makes runtime events machine-readable |
| Non-root container | Reduces container privileges |
| Ownership metadata | Identifies the responsible team |

The generated service is a starting point, not a locked framework. Developers can edit every file.

## What are developers actually testing?

The local workflow tests several different layers:

| Test | What it proves |
| --- | --- |
| `go test ./...` | Application behavior passes its automated tests |
| `go vet ./...` | Go code passes basic static analysis |
| Direct endpoint requests | The operational HTTP contract behaves correctly |
| Docker build | The source can become a repeatable container artifact |
| Docker health status | The packaged application is healthy at runtime |
| Non-root inspection | The runtime security setting is actually applied |
| Prometheus target status | Monitoring can discover and scrape the service |
| Prometheus query | Application metrics reach the monitoring system |
| Pull-request CI | The same checks work in a clean environment |
| OpenTofu validation | The optional cloud design is syntactically and structurally valid |

These tests do not prove that AWS is currently hosting the application. Only an actual cloud deployment can prove the AWS integration end to end, and that remains an explicit, potentially billable action.

## Workflow for a new Go service

### 1. Prepare the platform CLI

From the platform repository:

```bash
make test
make check
make build
./bin/platformctl doctor
```

Expected:

```text
status: ready
```

### 2. Create the service

```bash
./bin/platformctl new service \
  --name orders-api \
  --owner checkout-team \
  --output ./sandbox
```

Service names must contain 3–40 lowercase letters, numbers, or hyphens. The CLI refuses unsafe names and refuses to overwrite an existing directory.

### 3. Develop and test it directly

```bash
cd sandbox/orders-api
go test ./...
go run .
```

From another terminal:

```bash
curl http://localhost:8080/
curl http://localhost:8080/healthz
curl http://localhost:8080/readyz
curl http://localhost:8080/metrics
```

Press `Control+C` in the service terminal before starting the container so port `8080` becomes available.

### 4. Test the container

From the generated service directory:

```bash
docker build --tag orders-api:local .
docker run --rm --name orders-api -p 8080:8080 orders-api:local
```

From another terminal:

```bash
curl http://localhost:8080/healthz
docker inspect orders-api --format '{{.Config.User}}'
```

Expected:

```text
ok
nonroot:nonroot
```

Press `Control+C` to stop the foreground container.

### 5. Add application behavior

Replace or extend the example root handler with the service's real domain logic. Keep the health, readiness, metrics, logging, ownership, testing, and non-root container contracts intact.

Add tests for real behavior. A generated service test only proves that generation succeeded; it is not a substitute for application-specific tests.

### 6. Submit the change

The platform repository's CI demonstrates the expected gates:

- formatting
- tests
- static analysis
- CLI compilation
- fresh service generation
- generated-service tests
- container build
- vulnerability scanning
- OpenTofu formatting and validation

In a multi-repository platform, generated application repositories would call shared reusable versions of those workflows. That extraction is planned but not implemented yet.

## Running the included reference workload

The platform repository includes `examples/hello-api` to prove the workload contract.

Run only the API:

```bash
make demo
```

From another terminal in the repository root:

```bash
curl http://localhost:8080/
curl http://localhost:8080/healthz
curl http://localhost:8080/readyz
curl http://localhost:8080/metrics
docker compose ps
```

Run the API and Prometheus:

```bash
make observe
```

Then visit:

- API: `http://localhost:8080`
- Prometheus targets: `http://localhost:9090/targets`
- Prometheus query UI: `http://localhost:9090/query`

Generate traffic:

```bash
for number in 1 2 3 4 5; do
  curl --silent http://localhost:8080/
done
```

Query:

```promql
http_requests_total
```

Clean up:

```bash
make down
```

## Can I use this with an existing application?

Yes as an onboarding standard, but not yet as a one-command migration or deployment tool.

`platformctl new service` creates new Go services. It does not inspect or modify an existing repository. The current Compose and AWS workflows deploy the included `hello-api` reference workload, not arbitrary external applications.

To onboard an existing application today:

1. Identify its workload type: HTTP API, static site, background worker, stateful service, or real-time server.
2. Add deterministic application tests.
3. Add `/healthz` and `/readyz` where the workload type supports HTTP.
4. Expose Prometheus metrics or another approved telemetry format.
5. Add structured logging.
6. Build a minimal, non-root container.
7. Add `catalog-info.yaml` with the real owning team.
8. Add equivalent CI quality and security gates.
9. Create a local Compose definition for the app and its dependencies.
10. Select a deployment target appropriate for its runtime and state requirements.

What this gives an existing project is a consistent operational contract. It does not automatically make every architecture fit ECS. For example:

- A static frontend should have a static-web golden path rather than run as a permanent Go service.
- A WebSocket server needs long-lived connection and load-balancer testing.
- A database requires state, backup, recovery, and migration decisions.
- A worker may need queue health rather than an HTTP readiness endpoint.
- Uploaded files should use durable object storage rather than a container filesystem.

Those differences are why mature platforms provide multiple golden paths instead of one universal template.

## Current deployment boundary

There are three different meanings of “deploy” in this project:

| Action | Available now? | Meaning |
| --- | --- | --- |
| Run with `go run` | Yes | Starts the service directly on the developer's machine |
| Run with Docker/Compose | Yes | Runs a production-shaped container locally |
| Deploy the reference workload to AWS | Implemented but disabled | Protected workflow can publish and run `hello-api` if cloud resources are explicitly enabled |
| Deploy any generated repository to AWS | Not yet | Requires reusable workflows or a future `platformctl register` onboarding flow |

Local Docker is valuable because it tests the same container artifact shape intended for a deployment platform. It is not a public deployment: only the developer's machine can normally access `localhost`.

## Developer and platform responsibilities

| Developer owns | Platform owns |
| --- | --- |
| Business logic | Service template |
| Application-specific tests | Standard operational endpoints |
| Dependency choices | Baseline container security |
| Data and migration behavior | CI gate definitions |
| Correct readiness behavior | Observability conventions |
| Service ownership metadata | Deployment reference architecture |
| Responding to service alerts | Cost and security guardrails |

The platform removes repeated setup work; it does not remove application ownership.

## Definition of done for a supported service

A service is ready for platform onboarding when:

- tests pass
- static analysis passes
- `/healthz` returns success when the process is healthy
- `/readyz` only returns success when traffic can be accepted
- metrics are exposed and scrapeable
- logs identify the service and important events
- the container runs as a non-root user
- ownership metadata names a real team
- CI builds the same artifact developers tested
- secrets are not stored in source code or images
- state and dependencies have explicit operational plans

## Troubleshooting

### `target already exists`

The generator will not overwrite a directory. Choose a new service name or output directory.

### `bind: address already in use`

Another process is using port `8080`. Stop the previous `go run` or container before starting another runtime.

```bash
lsof -nP -iTCP:8080 -sTCP:LISTEN
```

### `no configuration file provided`

Run Compose commands from the platform repository containing `compose.yaml`:

```bash
cd /path/to/kwam-developer-platform
docker compose ps
```

### `docker compose` is unavailable

Install and start Docker Desktop, select the `desktop-linux` context, and confirm:

```bash
docker compose version
docker info
```

### Prometheus does not show the target

Confirm both containers are running:

```bash
docker compose --profile observe ps
```

Then open `http://localhost:9090/targets`. Prometheus scrapes every 15 seconds, so allow one interval after startup.

## What should developers read next?

- [Architecture](architecture.md) explains the control, workload, delivery, and observability planes.
- [Cost safety](cost-safety.md) explains why cloud resources remain disabled.
- [Roadmap](roadmap.md) identifies the remaining reusable-workflow and existing-app onboarding work.
