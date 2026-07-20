# Roadmap

## Phase 1 — local golden path

- [x] Self-service CLI
- [x] Secure service template
- [x] Health, readiness, and metrics contracts
- [x] Local container runtime
- [x] Prometheus integration
- [x] CI and IaC validation
- [x] Cost and architecture documentation

## Phase 2 — cloud delivery

- [ ] Add OIDC federation from GitHub to AWS (no stored AWS keys)
- [ ] Publish immutable images to ECR
- [ ] Add a scale-to-zero Lambda or low-cost container deployment path
- [ ] Add manual promotion and automated rollback verification
- [ ] Export OpenTelemetry traces, metrics, and logs

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
