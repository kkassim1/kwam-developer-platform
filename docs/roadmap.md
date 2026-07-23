# Roadmap

For verified evidence, current limitations, and the exact resume point, see [project status](project-status.md).

Checkboxes mean the implementation exists in the repository. They do not imply that optional AWS resources have been applied; cloud integration status is recorded separately below.

## Phase 1 — local golden path

- [x] Self-service CLI
- [x] Secure service template
- [x] Health, readiness, and metrics contracts
- [x] Local container runtime
- [x] Prometheus integration
- [x] CI and IaC validation
- [x] Cost and architecture documentation

## Phase 2 — cloud delivery

- [x] Add OIDC federation from GitHub to AWS (no stored AWS keys)
- [x] Publish immutable images to ECR
- [x] Add an opt-in ECS/Fargate container deployment path
- [x] Add protected manual promotion, health verification, rollback, and destroy
- [ ] Add HTTPS with an owned domain and ACM certificate
- [ ] Add preview environments with automatic expiration
- [ ] Export OpenTelemetry traces, metrics, and logs

Cloud integration status:

- [x] Both OpenTofu modules validate
- [x] Manual GitHub workflow passes static validation
- [ ] Bootstrap applied to an AWS account
- [ ] Reference service deployed and health-verified in AWS
- [ ] Failed deployment rollback exercised in AWS
- [ ] Destroy verified against all created resources

## Phase 2.5 — developer adoption

- [ ] Extract centrally owned reusable CI workflows
- [ ] Add reusable workflow callers to generated repositories
- [ ] Deploy a generated service instead of only the included reference workload
- [ ] Add `platformctl validate` for existing repositories
- [ ] Add safe, non-overwriting `platformctl register`
- [ ] Report deployment URL, artifact identity, observability links, and owner

## Phase 3 — internal developer portal

- [ ] Add a Backstage UI for the service template
- [ ] Register generated services in the software catalog
- [ ] Display CI, ownership, cost, and reliability scorecards
- [ ] Add policy-as-code guardrails
- [ ] Onboard Simon Says Assassin and DebateApp as example workloads

## Success measures

- A new developer can create and run a service in under five minutes.
- Every generated service exposes the same operational endpoints.
- CI rejects unsafe containers and invalid infrastructure.
- A local developer incurs no cloud cost.
- Cloud resources can be traced to an owner and budget.
